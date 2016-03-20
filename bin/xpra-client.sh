#!/bin/bash

startapp=${1:-firefox}
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
  --bind-tcp=:6000 \
  --exit-with-children \
  --daemon=no \
  --xvfb="Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER  -config ${HOME}/fixed-1024-xorg.conf" \
  --start-child=$startapp \
  $DISPLAY

# --html=:5000 \
#  --ssh="ssh -x -p 10024" \
#  ssh:user@address
