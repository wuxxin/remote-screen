#!/bin/bash
DISPLAY=$1
exec Xorg $DISPLAY -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER  -config ${HOME}/fixed-1024-xorg.conf
