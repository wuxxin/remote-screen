#!/bin/bash
set -e

if test "$1" = "ssh"; then
  shift

  if test -z "$REMOTE_VIEWONLY_PASSWORD" -o "$REMOTE_VIEWONLY_PASSWORD" = "unset"; then
    echo "generate viewonly password"
    REMOTE_VIEWONLY_PASSWORD=$(openssl rand 6 | python -c "import sys, base64; sys.stdout.write(base64.b32encode(sys.stdin.read()).lower())" | tr -d =)
    export REMOTE_VIEWONLY_PASSWORD
  fi

  if test -z "$REMOTE_READWRITE_PASSWORD" -o "$REMOTE_READWRITE_PASSWORD" = "unset"; then
    echo "generate read/write password"
    REMOTE_READWRITE_PASSWORD=$(openssl rand 6 | python -c "import sys, base64; sys.stdout.write(base64.b32encode(sys.stdin.read()).lower())" | tr -d =)
    export REMOTE_READWRITE_PASSWORD
  fi

  if test -z "$REMOTE_AUTOMATIC_VIEW" -o "$REMOTE_AUTOMATIC_VIEW" = "true"; then
    echo "integrate view password in index.html for noVNC"
    sed -r -i.bak "s/(password = WebUtil.getConfigVar\('password', ').+('\);)/\1$REMOTE_VIEWONLY_PASSWORD\2/g" /home/user/noVNC/index.html
    if test -f /home/user/noVNC/index.html.bak; then
      rm /home/user/noVNC/index.html.bak
    fi
  fi

  echo "write ~/vnc.pass (including READWRITE and VIEWONLY password)"
  cat > /home/user/vnc.pass << EOF
$REMOTE_READWRITE_PASSWORD
__BEGIN_VIEWONLY
$REMOTE_VIEWONLY_PASSWORD
EOF

  if test ! -e /etc/ssh/ssh_host_rsa_key; then
    echo "reconfigure ssh server keys"
    export LC_ALL=C
    export DEBIAN_FRONTEND=noninteractive
    dpkg-reconfigure openssh-server
  fi

  cd /home/user
  exec /usr/bin/supervisord -c /home/user/supervisord.conf "$@"
else
  exec "$@"
fi
