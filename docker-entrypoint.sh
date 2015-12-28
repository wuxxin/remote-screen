#!/bin/bash
set -e

if test "$1" = "ssh"; then
  shift
  exec /usr/bin/supervisord -c /app/supervisord.conf "$@"
else
  exec "$@"
fi
