xpra start \
  --sharing=yes \
  --readonly=no \
  --notifications=no \
  --speaker=off \
  --no-mdns \
  --pulseaudio=no \
  --printing=no \
  --clipboard=yes \
  --html=on \
  --bind-tcp=127.0.0.1:5000 \
  --exit-with-children \
  --daemon=no \
  --xvfb="Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER  -config ${HOME}/xorg.conf" \
  --ssh="ssh -x -p 10024" \
  --start-child=chromium-browser \
  ssh:user@remote-browser.omoikane.ep3.at
