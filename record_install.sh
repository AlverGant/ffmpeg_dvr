#!/bin/bash
# Ubuntu 16.04.4 Desktop 64 bits

# Update SO
sudo apt -y update && sudo apt -y upgrade

# Set timezone to Brazil UCT-3
echo "America/Sao Paulo" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Enable support for ExFAT and format removable drive
# for video recording, automount removable drive
# Plug drive before commands
sudo apt install -y exfat-fuse exfat-utils
sudo mkfs.exfat -n VIDEODRIVE /dev/sdb1
sudo fsck.exfat /dev/sdb1
mkdir -p /media/videodrive
echo '/dev/sdb1 /media/videodrive exfat defaults,auto,umask=000,users,rw 0 0' | sudo tee -a /etc/fstab
sudo mount -t exfat /dev/sdb1 /media/videodrive

# PREREQUISITES
sudo apt -y install autoconf build-essential \
git libasound2-dev libdbus-1-dev libflac-dev \
libfreetype6-dev libgl1-mesa-dev libjpeg-dev \
libmpg123-dev libpng-dev libsdl2-dev libsdl2-image-dev \
libsdl2-mixer-dev libsdl2-ttf-dev libssl-dev \
libtool libudev-dev libvorbis-dev libx11-dev \
make mercurial nasm openssl xorg-dev yasm \
libx264-dev libfdk-aac-dev v4l-utils libv4l-dev \
htop texinfo libfribidi-dev

# Clone, Compile and install Simple DirectMedia Layer
cd "${HOME}" || exit
hg clone https://hg.libsdl.org/SDL SDL
cd SDL || exit
make clean
./autogen.sh
./configure
make all -j "$(nproc)"
sudo make install
cd test || exit
make clean
./configure
sudo ln -s /usr/include/SDL2/SDL_ttf.h /usr/local/include/SDL2/
make all -j "$(nproc)"

# Clone, Compile and install FFMPEG
# Enable support for H264, AAC and video4linux capture
cd "${HOME}" || exit
git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg || exit
git pull
./configure \
	--enable-gpl \
	--enable-nonfree \
	--enable-openssl \
    	--enable-libx264 \
    	--enable-libfdk-aac \
    	--enable-libv4l2 \
    	--enable-libfreetype \
    	--enable-libfontconfig \
    	--enable-libfribidi
make -j "$(nproc)"
sudo make install

# configure autologon for the user
# Disable screen blackout and lock
sudo gsettings set org.gnome.desktop.session idle-delay 0
sudo gsettings set org.gnome.desktop.screensaver lock-enabled false

# Disable power management and screen blanking
echo "export DISPLAY=:0" >> "${HOME}"/.profile
echo "xset s off && xset s noblank && xset -dpms" >> "${HOME}"/.profile

# Set permissions to access webcam for current user
sudo usermod -a -G video "$USER"
sudo usermod -a -G audio "$USER"
sudo chmod g+rw /dev/video0

# Install node.js
sudo apt install -y nodejs npm

cd "${HOME}"/ffmpeg_dvr || exit
sudo cp record_cam1.sh /opt/record_cam1.sh
sudo cp record_cam2.sh /opt/record_cam2.sh
sudo cp daemon.js /opt/daemon.js

# Prepare record daemon
sudo cp record.service /lib/systemd/system/record.service
sudo chmod 644 /lib/systemd/system/record.service
sudo systemctl daemon-reload
sudo systemctl enable record.service

