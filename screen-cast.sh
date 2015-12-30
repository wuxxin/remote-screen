#!/bin/bash


echo "unfinished, look at the source"
exit 1

add to Dockerfile
  vlc-nox \
  ffmpeg \

Examples with vlc and ffmpeg streaming


ffmpeg -f x11grab -s 1024x768 -r 20 -i :10.0 -vcodec libx264 -preset fast -tune fastdecode -crf 28 -threads 8 -f mpegts pipe:1 | vlc - -I dummy --sout '#standard{access=http,mux=ts,dst=:5000/}'  :demux=ts  :network-caching=0

ffmpeg -f x11grab -s 1024x768 -r 10 -i :0.0 -vcodec libx264 -preset ultrafast -tune zerolatency -threads 8 -f mpegts pipe:1 | vlc - -I dummy --sout '#standard{access=http,mux=ts,dst=:5000/}'  :demux=ts

#
https://wiki.videolan.org/Documentation:Streaming_HowTo/Streaming_for_the_iPhone/

cvlc screen:// \
  :screen-fps=15 \
  :live-caching=0 \
  --sout '#transcode{vcodec=mp4v,vb=1800,acodec=none}:standard{access=http,mux=ts,dst=:5000/}' \
  --sout-keep \
  --no-sout-audio

  cvlc screen:// \
    :screen-fps=10 \
    :live-caching=300 \
    --sout '#transcode{vcodec=theo,vb=2000,threads=4,acodec=none}:standard{access=http,mux=ogg,dst=:5000/}' \
    --sout-keep \
    --no-sout-audio


    --sout-x264-profile=baseline \
    --sout-x264-keyint=10 \
    --sout-x264-bframes=0 \
    --sout-x264-preset=ultrafast \
    --sout-x264-tune=zerolatency \
