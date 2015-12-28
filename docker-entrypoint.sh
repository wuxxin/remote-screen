#!/bin/bash
set -e

if test "$1" = "ssh"; then
  shift
  exec /usr/bin/supervisord -c /etc/supervisor/conf.d/openssh.conf "$@"
else
  exec "$@"
fi
