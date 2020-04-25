#! /bin/env bash

# https://www.kpromise.top/run-wechat-in-linux/
# https://github.com/bestwu/docker-wechat
docker kill wechat > /dev/null 2>&1
docker run --name wechat --rm -d \
    --device /dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/projects/docker/wechat/:/WeChatFiles \
    -e DISPLAY=unix$DISPLAY \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
    bestwu/wechat
