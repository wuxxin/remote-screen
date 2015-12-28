FROM ubuntu:wily
MAINTAINER Felix Erkinger <wuxxin@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Support xpra, xserver-xspice
# xpra has a html5 client, spice has a html5 client

COPY xpra_signing.key /tmp
RUN apt-key add /tmp/xpra_signing.key
RUN echo "deb https://www.xpra.org/ wily main" > /etc/apt/sources.list.d/xpra.list
# XXX: xpra.org hase some minor https quirks, we work around that because packages are signed
# XXX: we also set not to use a proxy to connect to xpra, because apt-cacher-ng fails in doing so
RUN echo 'Acquire::https::www.xpra.org::Verify-Peer "false";' > /etc/apt/apt.conf.d/40xpra-https-exception
RUN echo 'Acquire::https::proxy::www.xpra.org "DIRECT";' >> /etc/apt/apt.conf.d/40xpra-https-exception

RUN set -x; \
    apt-get update \
    && apt-get install -y \
    supervisor \
    openssh-server \
    git \
    websockify \
    xserver-xspice \
    spice-vdagent \
    xserver-xorg-video-dummy \
    xpra \
    python-gst-1.0 \
    chromium-browser \
    firefox \
    && rm -rf /var/lib/apt/lists/*


# setup locale
ENV LANG en_US.UTF-8
ENV LC_TYPE en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN echo -e "LANG=en_US.UTF-8\nLC_TYPE=en_US.UTF-8\nLC_MESSAGES=POSIX\nLANGUAGE=en" > /etc/default/locale
RUN locale -a

# Add supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/openssh.conf

# Add user to run the application
COPY authorized_keys /tmp/authorized_keys
RUN adduser user --disabled-password; \
    mkdir -p /home/user/.ssh; \
    chmod 700 /home/user/.ssh; \
    cp -f /tmp/authorized_keys /home/user/.ssh/authorized_keys; \
    chmod 600 /home/user/.ssh/authorized_keys; \
    chown -R user:user /home/user/.ssh

# spice-html5 client
RUN cd /home/user; \
    git clone http://anongit.freedesktop.org/git/spice/spice-html5.git/ spice-html5; \
    chown -R user:user /home/user/spice-html5

# ssh config
RUN sed -i.bak 's/.*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; \
  rm /etc/ssh/sshd_config.bak; \
  mkdir /var/run/sshd;

EXPOSE 22 5000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
