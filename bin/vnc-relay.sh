#!/bin/bash

echo "unfinished"
exit 1


novnc -reflect localhost:5900 -autoport 5910 -forever &
websockify --auto-pong --heartbeat=58 --web /home/user/noVNC/ 5000 localhost:5900 &
