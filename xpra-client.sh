#!/bin/bash

startapp=${1:-chromium-browser}
export DISPLAY=:10
xpra start \
  --sharing=yes \
  --readonly=no \
  --notifications=no \
  --speaker=off \
  --no-mdns \
  --pulseaudio=no \
  --printing=no \
  --clipboard=yes \
  --html=:5000 \
  --bind-tcp=:6000 \
  --exit-with-children \
  --daemon=no \
  --xvfb="Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER  -config ${HOME}/xpra-xorg.conf" \
  --start-child=$startapp \
  $DISPLAY

#  --ssh="ssh -x -p 10024" \
#  ssh:user@address
