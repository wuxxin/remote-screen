FROM ubuntu:wily
MAINTAINER Felix Erkinger <wuxxin@gmail.com>

ENV REMOTE_TITLE remote-screen
ENV REMOTE_VIEWONLY_PASSWORD unset
ENV REMOTE_READWRITE_PASSWORD unset
ENV REMOTE_AUTOMATIC_VIEW true

# we run upgrade (bad container practice) to workaround old "official" docker images (also bad practice, but this time from docker inc)

ENV DEBIAN_FRONTEND noninteractive
RUN set -x; \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    apt-transport-https \
    python-software-properties \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# xpra repo
COPY xpra_signing.key /tmp
RUN apt-key add /tmp/xpra_signing.key
RUN echo "deb https://www.xpra.org/ wily main" > /etc/apt/sources.list.d/xpra.list
# XXX: xpra.org hase some minor https quirks, we work around that because packages are signed
# XXX: also set not to use a proxy to connect to xpra, because apt-cacher-ng fails in doing so
RUN echo 'Acquire::https::www.xpra.org::Verify-Peer "false";' > /etc/apt/apt.conf.d/40xpra-https-exception
RUN echo 'Acquire::https::proxy::www.xpra.org "DIRECT";' >> /etc/apt/apt.conf.d/40xpra-https-exception

RUN set -x; \
    apt-get update \
    && apt-get install -y \
    man-db \
    net-tools \
    curl \
    supervisor \
    openssh-server \
    git \
    mercurial \
    libx11-dev \
    xbindkeys \
    psmisc \
    xserver-xspice \
    spice-vdagent \
    xserver-xorg-video-dummy \
    openbox \
    x11vnc \
    xinit \
    xvfb \
    xpra \
    python-gst-1.0 \
    chromium-browser \
    firefox \
    evince \
    python-pip \
    python3-pip \
    openssl \
    gdebi-core \
    && rm -rf /var/lib/apt/lists/*

# delete ssh host keys regenerate them on deploy
RUN rm /etc/ssh/ssh_host_*_key*

# install from pypi: websockify for python3 because 0.7 is currently only available for py3
RUN pip3 install websockify

# install the latest atom (nice to have)
#RUN curl -o /tmp/atom.deb -L https://atom.io/download/deb && gdebi -n /tmp/atom.deb

# setup locale
ENV LANG en_US.UTF-8
ENV LC_TYPE en_US.UTF-8
RUN echo -e "LANG=en_US.UTF-8\nLC_TYPE=en_US.UTF-8\nLC_MESSAGES=POSIX\nLANGUAGE=en" > /etc/default/locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN locale -a

# ssh config
RUN sed -i.bak 's/.*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; \
 rm /etc/ssh/sshd_config.bak; \
 mkdir /var/run/sshd;

# Add user to run the application, update authorized_keys, add symlinks to volume data
COPY authorized_keys /tmp/authorized_keys
RUN adduser --disabled-password --gecos "" user; \
    mkdir -p /home/user/.ssh; \
    chmod 700 /home/user/.ssh; \
    cp -f /tmp/authorized_keys /home/user/.ssh/authorized_keys; \
    chmod 600 /home/user/.ssh/authorized_keys; \
    chown -R user:user /home/user/.ssh; \
    for a in .config .pki; do \
      mkdir -p /data/$a; \
      ln -s /data/$a /home/user/$a; \
    done; \
    chown -R user:user /data


USER user
WORKDIR /home/user

# client shell scripts to ~/bin
COPY bin /home/user/bin

# Add supervisor configuration
COPY supervisord.conf /home/user/supervisord.conf

# get & compile findcursor
RUN hg clone https://bitbucket.org/Carpetsmoker/find-cursor \
    && cd find-cursor \
    && sed -i.bak "s/int speed = 400;/int speed = 800;/g" find-cursor.c \
    && rm find-cursor.c.bak \
    && make

# xbindkeys config
COPY xbindkeysrc /home/user/.xbindkeysrc

# x11 config for both vnc and xpra
COPY fixed-1024-xorg.conf /home/user/fixed-1024-xorg.conf

# spice html5 client
RUN git clone http://anongit.freedesktop.org/git/spice/spice-html5.git/ spice-html5
COPY xspice-xorg.conf xspice-xorg.conf

# novnc html5 client
RUN git clone https://github.com/kanaka/noVNC.git noVNC
COPY novnc.index.html /home/user/noVNC/index.html
RUN sed -i.bak "s/REMOTE_TITLE/$REMOTE_TITLE/g" /home/user/noVNC/index.html \
    && rm /home/user/noVNC/index.html.bak

# root from here
USER root

# xpra client patch
COPY xpra-html5 /usr/share/xpra/www

# copy find-cursor to system wide /usr/local/bin
RUN cp /home/user/find-cursor/find-cursor /usr/local/bin/find-cursor

# copy possible custom configuration to container, and execute custom_root.sh from it
ONBUILD COPY custom /home/user/custom
ONBUILD RUN chown -R user:user /home/user/custom \
    &&  if test -f /home/user/custom/*.sh; then \
          chmod +x /home/user/custom/*.sh \
        fi \
    &&  if test -f  /home/user/custom/custom_root.sh; then \
          /home/user/custom/custom_root.sh \
        fi

# recreate ssh host keys
ONBUILD RUN if test ! -e /etc/ssh/ssh_host_rsa_key; then \
      echo "reconfigure ssh server keys" \
      export LC_ALL=C \
      export DEBIAN_FRONTEND=noninteractive \
      dpkg-reconfigure openssh-server \
    fi

# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/data"]
EXPOSE 22 5000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ssh"]
