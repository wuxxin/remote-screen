#!/bin/bash
DISPLAY=$1
shift

read REMOTE_READWRITE_PASSWORD dummy REMOTE_VIEWONLY_PASSWORD <<< "$(for a in `cat $HOME/vnc.pass`; do echo -n "$a "; done )"

echo "Waiting 3 seconds for Xorg to start"
sleep 3

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
