#!/bin/bash

#This script will compile and install a static ffmpeg build with support for nvenc un ubuntu.
#See the prefix path and compile options if edits are needed to suit your needs.

#install required things from apt
installLibs(){
echo "Installing prerequisites"
sudo apt-get update
sudo apt-get -y --force-yes install autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev
}

#Install nvidia SDK
installSDK(){
echo "Installing the nVidia NVENC SDK."
cd ~/ffmpeg_sources
mkdir SDK
cd SDK
wget http://developer.download.nvidia.com/compute/nvenc/v5.0/nvenc_5.0.1_sdk.zip -O sdk.zip
unzip sdk.zip
cd nvenc_5.0.1_sdk
sudo cp Samples/common/inc/* /usr/include/
}

#Compile yasm
compileYasm(){
echo "Compiling yasm"
cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean
}

#Compile libx264
compileLibX264(){
echo "Compiling libx264"
cd ~/ffmpeg_sources
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
PATH="$HOME/bin:$PATH" make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean
}

#Compile libfdk-acc
compileLibfdkcc(){
echo "Compiling libfdk-cc"
sudo apt-get install unzip
cd ~/ffmpeg_sources
wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
unzip fdk-aac.zip
cd mstorsjo-fdk-aac*
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean
}

#Compile libmp3lame
compileLibMP3Lame(){
echo "Compiling libmp3lame"
sudo apt-get install nasm
cd ~/ffmpeg_sources
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared
make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean
}

#Compile libopus
compileLibOpus(){
echo "Compiling libopus"
cd ~/ffmpeg_sources
wget http://downloads.xiph.org/releases/opus/opus-1.1.3.tar.gz
tar xzvf opus-1.1.3.tar.gz
cd opus-1.1.3
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean
}

#Compile libvpx
compileLibPvx(){
echo "Compiling libvpx"
cd ~/ffmpeg_sources
wget storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.6.0.tar.bz2
tar xjvf libvpx-v1.6.0.tar.bz2
cd libvpx-v1.6.0
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples
PATH="$HOME/bin:$PATH" make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) clean
}

#Compile ffmpeg
compileFfmpeg(){
echo "Compiling ffmpeg"
cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-vaapi \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-nonfree \
  --enable-nvenc
PATH="$HOME/bin:$PATH" make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean
hash -r
}

#The process
cd ~
mkdir ffmpeg_sources
installLibs
installSDK
compileYasm
compileLibX264
compileLibfdkcc
compileLibMP3Lame
compileLibOpus
compileLibPvx
compileFfmpeg
echo "Complete!"