#!/bin/bash

export DISPLAY=:10
Xspice \
  $DISPLAY \
  --config /home/user/xspice-xorg.conf \
  --port 5910 \
  --disable-ticketing \
  --tls-port 0 \
  -dpi 96 \
  -nolisten tcp \
  +extension RANDR \
  +extension RENDER \
  -noreset &

  #--vdagent \
  #+extension GLX \
websockify --web /home/user/spice-html5/ 5000 0.0.0.0:5910 &
firefox
