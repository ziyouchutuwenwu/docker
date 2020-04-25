#! /bin/env bash

# https://github.com/bestwu/docker-qq
docker kill qq > /dev/null 2>&1
docker run --name qq --rm -d \
    --device /dev/snd \
    -v ~/projects/docker/qq/:/TencentFiles \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e DISPLAY=unix$DISPLAY \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e VIDEO_GID=`getent group video | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
    bestwu/qq:office
