#!/bin/bash


gst-launch-1.0 -v   rfbsrc view-only=true shared=true ! decodebin ! autovideoconvert !   video/x-raw,format=YV12,width=1024,height=768,framerate=10/1 ! x264enc bitrate=1000 speed-preset=fast  ! video/x-h264,profile=baseline ! h264parse ! queue !  flvmux name=mux pulsesrc ! queue ! avenc_aac ! queue ! mux. mux. ! rtmpsink location=\"rtmp://localhost/myapp/mystream live=1\"

gst-launch-1.0 -v   rfbsrc view-only=true shared=true ! decodebin ! autovideoconvert !   video/x-raw,format=YV12,width=1024,height=768,framerate=10/1 ! x264enc bitrate=1000 speed-preset=fast  ! video/x-h264,profile=baseline ! h264parse ! queue !  flvmux name=mux pulsesrc ! queue ! voaacenc ! queue ! mux. mux. ! rtmpsink location=\"rtmp://localhost/myapp/mystream live=1\"

video/r-raw,format=RGB,width=1024,height=768,framerate=10/1

rfbsrc host=10.9.140.21 password=cpbtjgbia4 view-only=true shared=true

gst-launch-1.0 rfbsrc incremental=false host=10.9.140.21 password=cpbtjgbia4 view-only=true shared=true ! video/x-raw,format=RGB,width=1024,height=768,framerate=10/1 ! videoconvert ! x264enc bitrate=1000 speed-preset=fast  ! video/x-h264,profile=baseline ! filesink location=data.h264

gst-launch-1.0 rfbsrc host=10.9.140.21 password=cpbtjgbia4 view-only=true shared=true ! decodebin ! autovideoconvert !   video/x-raw,format=YV12,width=1024,height=768,framerate=10/1 ! x264enc bitrate=1000 speed-preset=fast  ! video/x-h264,profile=baseline ! h264parse ! queue !  flvmux name=mux pulsesrc ! queue ! voaacenc ! queue ! mux. mux. ! rtmpsink location=\"rtmp://localhost/myapp/mystream live=1\"

  queue ! \
  theoraenc ! oggmux ! tcpserversink

echo "unfinished, look at the source"
exit 1

gst-launch


x264enc bitrate=500 speed-preset=superfast

gst-launch -q \
  rfbsrc view-only=true incremental=false ! \
  decodebin ! colorspace ! videoscale ! videorate ! \
  video/x-raw-yuv,width=640,height=480,framerate=10/1 ! \
  queue ! \
  theoraenc ! oggmux ! tcpserversink

  gst-launch-1.0 v4l2src  ! "video/x-raw,width=640,height=480,framerate=15/1" !
  h264enc bitrate=1000 ! video/x-h264,profile=high ! h264parse ! queue !
  flvmux name=mux alsasrc device=hw:1 ! audioresample ! audio/x-raw,rate=48000 !
  queue ! voaacenc bitrate=32000 ! queue ! mux. mux. !
  rtmpsink location=\"rtmp://example.com/myapp/mystream live=1\"


remark: GStreamer rtmpsink plugin writes long timestamps in type-3 packets in a different way than ffmpeg rtmp engine. So the following directive is needed in nginx.conf when publishing with GStreamer.

publish_time_fix off;


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
