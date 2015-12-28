#!/bin/bash
set -e

if test "$1" = ""; then
  exec /usr/bin/supervisord -c /app/supervisord.conf "$@"
else
  exec "$@"
fi
