#!/bin/bash

GST_DEBUG="rfbsrc:6" gst-launch-1.0 rfbsrc host=10.9.140.21 password=cpbtjgbia4 incremental=true view-only=true shared=true ! video/x-raw, format=BGRx, framerate=10/1, width=1024, height=768 ! decodebin ! videoconvert ! x264enc bitrate=1000 speed-preset=fast ! video/x-h264, profile=baseline ! flvmux ! filesink location=test.flv

GST_DEBUG="rfbsrc:4" gst-launch-1.0 rfbsrc host=10.9.140.21 password=cpbtjgbia4 incremental=true view-only=true shared=true ! video/x-raw, format=BGRx, framerate=10/1, width=1024, height=768 ! decodebin ! videoconvert ! x264enc bitrate=1000 speed-preset=fast ! video/x-h264, profile=baseline ! h264parse ! queue ! flvmux name=mux pulsesrc ! queue ! voaacenc ! queue ! mux. mux. ! rtmpsink location=\"rtmp://localhost/myapp/mystream live=1\"

GST_DEBUG="rfbsrc:4" gst-launch-1.0 rfbsrc host=10.9.140.21 password=cpbtjgbia4 incremental=true view-only=true shared=true ! video/x-raw, format=BGRx, framerate=10/1, width=1024, height=768 ! decodebin ! videoconvert ! x264enc bitrate=1500 speed-preset=superfast ! video/x-h264, profile=baseline ! h264parse ! queue ! flvmux name=mux pulsesrc ! queue ! voaacenc ! queue ! mux. mux. ! filesink location=test.flv


gst-launch-1.0 \
flvmux name=mux ! filesink location=test.flv \
pulsesrc ! queue max-size-bytes=0 max-size-buffers=0 max-size-time=0 ! voaacenc ! queue ! mux. \
rfbsrc host=10.9.140.21 password=cpbtjgbia4 incremental=false view-only=true shared=true ! video/x-raw, format=BGRx, framerate=3/1, width=1024, height=768 ! decodebin ! queue ! videoconvert ! x264enc bitrate=200 speed-preset=superfast tune=zerolatency byte-stream=true ! video/x-h264, profile=baseline ! h264parse ! queue ! mux.

GST_DEBUG="rfbsrc:4" ./test-launch \
flvmux name=flvmux ! filesink location=test.flv \
rfbsrc host=10.9.140.21 password=cpbtjgbia4 incremental=false view-only=true shared=true ! video/x-raw, format=BGRx, framerate=3/1, width=1024, height=768 ! decodebin ! queue ! videoconvert ! x264enc bitrate=750 speed-preset=superfast tune=zerolatency byte-stream=true threads=2 ! video/x-h264, profile=baseline ! h264parse !  tee name=flvmux ! rtph264pay pt=96 name=pay0 \
pulsesrc ! queue max-size-bytes=0 max-size-buffers=0 max-size-time=0 ! voaacenc ! tee name=flvmux ! rtpmp4apay pt=97 name=pay1 \


rtph264pay
  udpsink bind-address:10.9.143.138 bind-port:42050 sync=false

  udpsink host=127.0.0.1 port=42050 sync=false
 udpsink host=192.168.0.103 port=5000 auto-multicast=true

 x264enc: Add speed-preset and [psy-]tuning properties

 Use of a rate control method (pass, bitrate, quantizer, etc properties), a
 preset and possibly a profile and/or tuning are now the recommended way to
 configure x264 through x264enc.

 If a preset/tuning are specified then these will define the default values and
 the property defaults will be ignored. After this the option-string property is
 applied, followed by the user-set properties, fast first pass restrictions and
 finally the profile restrictions

  Enum "GstX264EncPass" Default: 0, "cbr"
  (0): cbr - Constant Bitrate Encoding
  (4): quant - Constant Quantizer (debugging only)
  (5): qual - Constant Quality
  (17): pass1 - VBR Encoding - Pass 1
  (18): pass2 - VBR Encoding - Pass 2
  (19): pass3 - VBR Encoding - Pass 3

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
