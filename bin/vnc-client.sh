#!/bin/bash
export DISPLAY=:10

read -r -a vncpass < $HOME/vnc.pass
REMOTE_READWRITE_PASSWORD="${vncpass[0]}"
REMOTE_VIEWONLY_PASSWORD="${vncpass[2]}"

Xorg $DISPLAY -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER  -config ${HOME}/xpra-xorg.conf &
x11vnc -xdummy -display $DISPLAY -viewpasswd $REMOTE_VIEWONLY_PASSWORD -passwd $REMOTE_READWRITE_PASSWORD -rfbport 5900 -forever -shared  &
websockify --auto-pong --heartbeat=58 --web /home/user/noVNC/ 5000 localhost:5900 &
openbox &
xbindkeys_autostart &
cat << EOF
INFORMATION:
------------

Read/Write Password: $REMOTE_READWRITE_PASSWORD
View only Password: $REMOTE_VIEWONLY_PASSWORD
you can show your mouse position using CTRL+ Left Mouse Button

EOF

if test -z "$1" ; then chromium-browser; else $@; fi
