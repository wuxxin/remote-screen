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
    xvfb \
    xpra \
    python-gst-1.0 \
    chromium-browser \
    firefox \
    evince \
    python-pip \
    openssl \
    gdebi-core \
    && rm -rf /var/lib/apt/lists/*

# delete ssh host keys regenerate them on deploy
RUN rm /etc/ssh/ssh_host_*_key*

# install from pypi: websockify for python2/3
RUN pip install websockify

# install the latest atom (nice to have)
#RUN curl -o /tmp/atom.deb -L https://atom.io/download/deb && gdebi -n /tmp/atom.deb

# setup locale
ENV LANG en_US.UTF-8
ENV LC_TYPE en_US.UTF-8
RUN echo -e "LANG=en_US.UTF-8\nLC_TYPE=en_US.UTF-8\nLC_MESSAGES=POSIX\nLANGUAGE=en" > /etc/default/locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN locale -a

# Add supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/openssh.conf

# client shell scripts
COPY bin /usr/local/bin

# ssh config
RUN sed -i.bak 's/.*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; \
 rm /etc/ssh/sshd_config.bak; \
 mkdir /var/run/sshd;

# Add user to run the application
COPY authorized_keys /tmp/authorized_keys
RUN adduser --disabled-password --gecos "" user; \
    mkdir -p /home/user/.ssh; \
    chmod 700 /home/user/.ssh; \
    cp -f /tmp/authorized_keys /home/user/.ssh/authorized_keys; \
    chmod 600 /home/user/.ssh/authorized_keys; \
    chown -R user:user /home/user/.ssh

USER user
WORKDIR /home/user

# get & compile findcursor
RUN hg clone https://bitbucket.org/Carpetsmoker/find-cursor \
    && cd find-cursor \
    && sed -i.bak "s/(int speed =) 400;/\1 800;/g" find-cursor.c \
    && rm find-cursor.c.bak \
    && make

# spice html5 client
RUN git clone http://anongit.freedesktop.org/git/spice/spice-html5.git/ spice-html5
COPY xspice-xorg.conf xspice-xorg.conf

# novnc html5 client
RUN git clone https://github.com/kanaka/noVNC.git noVNC
COPY novnc.index.html /home/user/noVNC/index.html
RUN sed -i.bak "s/{{ REMOTE_TITLE }}/$REMOTE_TITEL/g" /home/user/noVNC/index.html \
    && rm /home/user/noVNC/index.html.bak

# xpra config and html5 client patch
COPY xpra-xorg.conf /home/user/xpra-xorg.conf

# make a xbindkeys config
cat > /home/user/.xbindkeysrc << EOF
"/usr/local/bin/find-cursor"
  control + b:1
EOF

# root from here
USER root
COPY xpra-html5 /usr/share/xpra/www
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

# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 22 5000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ssh"]
