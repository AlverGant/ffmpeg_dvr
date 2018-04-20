
v4l2-ctl -d /dev/video0 -c focus_auto=0
v4l2-ctl -d /dev/video0 -c focus_absolute=0

# Enable for low light situations
#v4l2-ctl -c exposure_auto=1
#v4l2-ctl -c exposure_absolute=10
#v4l2-ctl -c brightness=180

# List devices
v4l2-ctl --list-devices

# List available formats
v4l2-ctl --list-formats-ext
ffmpeg -f v4l2 -list_formats all -i /dev/video0

v4l2-ctl --info

# List audio capture devices
arecord -l 

# List camera controls
v4l2-ctl --list-ctrls


ffmpeg -f video4linux2 -video_size 320x240 -i /dev/video0 -vcodec libx264 -crf 20 -intra-refresh 1 \
-preset veryfast -tune zerolatency -g 1 -f mpegts udp://192.168.255.74:2222

ffmpeg -f video4linux2 -input_format mjpeg -s 1280x720 -i /dev/video0 \
-vf "drawtext=fontfile=/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf: \
text='%{localtime\:%T}': fontcolor=white@0.8: x=7: y=700" -vcodec libx264 \
-preset veryfast -f mp4 -pix_fmt yuv420p -y output.mp4


ffmpeg -thread_queue_size 128 -f alsa -ac 2 -i "hw:CARD=C920,DEV=0" \
-thread_queue_size 128 -f video4linux2 -input_format mjpeg -framerate 30 \
-video_size 1920x1080 -i /dev/video0 -vcodec libx264 \
-preset veryfast \
-af dynaudnorm=s=3:f=60 \
-y /media/deped/VIDEODRIVE/captura.mp4

fffmpeg -thread_queue_size 128 -f alsa -ac 1 -i "hw:CARD=HD3000,DEV=0" \
-thread_queue_size 128 -f video4linux2 -input_format mjpeg -framerate 30 \
-video_size 1280x720 -i /dev/video0 -vcodec libx264 \
-preset veryfast \
-af dynaudnorm=s=3 \
-y /media/deped/VIDEODRIVE/captura.mp4

ffmpeg -thread_queue_size 128 -f alsa -ac 2 -i "hw:CARD=AK5370,DEV=0" \
-thread_queue_size 128 -f video4linux2 -input_format mjpeg -framerate 30 \
-video_size 1280x720 -i /dev/video0 -vcodec libx264 \
-preset veryfast \
-af dynaudnorm=s=3:f=30 \
-y /media/deped/VIDEODRIVE/captura.mp4




Ubuntu NUC remote control

INFRARED OPTION (mais simples)
START REC
STOP REC
UNMOUT DRIVE
1 DATETIME UPPER LEFT
3 DATETIME UPPER RIGHT
7 DATETIME LOWER LEFT
9 DATETIME LOWER RIGHT

WIFI (complicado)
Access point with Flask application

BLUETOOTH KEYBOARD (tosco)
KEYBOARD SHORTCUTS for START STOP UNMOUNT

LEDS para REC e MOUNT
