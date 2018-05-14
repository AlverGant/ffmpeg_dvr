#!/bin/bash

pid=$(pgrep -xn pulseaudio)\
  && export DBUS_SESSION_BUS_ADDRESS="$(grep -ao -m1 -P '(?<=DBUS_SESSION_BUS_ADDRESS=).*?\0' /proc/"$pid"/environ)"
CAMERA_TYPE=$(v4l2-ctl --info -d /dev/video0 | grep type | cut -d':' -f 2 | tr -d ' ')
SEGMENT_TIME=60
QUEUE_SIZE=512

if [ "$CAMERA_TYPE" = "HDProWebcamC920" ]; then
	AUDIO_DEVICE="hw:CARD=C920,DEV=0"
	RESOLUTION="1920x1080"
	AUDIO_CHANNELS=2
fi
if [ "$CAMERA_TYPE" = "Microsoft®LifeCamHD-3000" ]; then
        AUDIO_DEVICE="hw:CARD=HD3000,DEV=0"
        RESOLUTION="1280x720"
	AUDIO_CHANNELS=1
fi
if [ "$CAMERA_TYPE" = "Microsoft®LifeCamHD-5000" ]; then
        AUDIO_DEVICE="hw:CARD=HD5000,DEV=0"
        RESOLUTION="1280x720"
	AUDIO_CHANNELS=1
fi

ffmpeg -thread_queue_size $QUEUE_SIZE \
  -f alsa -ac $AUDIO_CHANNELS -i $AUDIO_DEVICE \
  -thread_queue_size $QUEUE_SIZE -f video4linux2 \
  -input_format mjpeg -framerate 30 -video_size $RESOLUTION -i /dev/video0 \
  -pix_fmt yuv420p -vcodec libx264 -preset superfast -af dynaudnorm=s=3:f=60 \
  -vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf: text='%{localtime\:%a %b %d %Y %T} - $1': fontcolor=white: fontsize=24: box=1: boxcolor=black@0.5: y=0: x=0" \
  -f segment -segment_time $SEGMENT_TIME \
  "$2"/"$(date +%s)"_%04d.mp4

