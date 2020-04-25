#! /bin/env bash

# https://github.com/bestwu/docker-thunderspeed
docker kill thunder > /dev/null 2>&1
docker run --name thunder --rm -d \
    --device /dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/downloads:/迅雷下载 \
    -e DISPLAY=unix$DISPLAY \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
    bestwu/thunderspeed