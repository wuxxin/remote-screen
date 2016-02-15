#!/bin/bash
DISPLAY=:10
export DISPLAY=$DISPLAY

exec /usr/bin/xinit /home/user/bin/_start_xsession.sh $DISPLAY $@ -- /home/user/bin/_start_xserver.sh $DISPLAY 
