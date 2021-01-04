FROM 0x01be/xpra:build as build

FROM 0x01be/base as uinput

RUN apk add py3-pip build-base python3-dev linux-headers eudev
RUN pip3 install --prefix=/opt/uinput python-uinput

FROM 0x01be/base

COPY --from=build /opt/xpra/bin/ /usr/bin/
COPY --from=build /opt/xpra/lib/python/ /usr/lib/python3.8/site-packages/
COPY --from=uinput /opt/uinput/ /opt/uinput/
COPY --from=build /opt/xpra/share/xpra/ /usr/share/xpra/
COPY --from=build /opt/xpra/etc/xpra/ /etc/xpra/
COPY --from=build /opt/xpra/etc/X11/xorg.conf.d/ /etc/X11/xorg.conf.d/
COPY --from=build /opt/xpra/etc/dbus-1/system.d/ /etc/dbus-1/system.d/

ENV UID=1000 \
    USER=xpra \
    WORKSPACE=/home/xpra \
    PORT=10000 \
    COMMAND="echo ***TODO***" \
    SCREEN="1280x800x24+32"
ENV FRAMEBUFFER="/usr/bin/Xvfb +extension GLX +extension RANDR +extension RENDER +extension Composite -screen 0 ${SCREEN} -nolisten tcp -noreset" \
    INTERFACE="0.0.0.0:${PORT}" \
    SHARING=yes \
    PYTHONPATH=/usr/lib/python3.8/site-packages:/opt/uinput/lib/python3.8/site-packages

RUN apk add --no-cache --virtual xpra-runtime-dependencies \
    python3 \
    py3-gobject3 \
    py3-rencode \
    py3-pillow \
    py3-cairo \
    py3-xdg \
    py3-dbus \
    py3-requests \
    py3-lz4 \
    py3-paramiko \
    py3-netifaces \
    dbus-x11 \
    gstreamer \
    xvfb \
    gtk+3.0 \
    gnome-icon-theme \
    ttf-freefont \
    ffmpeg \
    jpeg \
    x264 \
    pulseaudio \
    gstreamer \
    alsa-lib \
    pulseaudio-alsa \
    alsa-plugins-pulse \
    eudev &&\
    apk add --no-cache --virtual xpra-edge-runtime-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    py3-inotify &&\
    adduser -D -u ${UID} ${USER} &&\
    mkdir -p /run/user/${UID}/${USER} &&\
    mkdir -p /run/${USER} &&\
    mkdir -p ${WORKSPACE}/.config/pulse &&\
    chown -R ${USER}:${USER} /run/user/${UID}/${USER} &&\
    chown -R ${USER}:${USER} /run/${USER} &&\
    chown -R ${USER}:${USER} ${WORKSPACE} &&\
    mkdir -p /tmp/.X11-unix &&\
    chmod 1777 /tmp/.X11-unix &&\
    chmod -R 775 /run/${USER} &&\
    chmod -R 700 /run/user/${UID}/${USER} &&\
    mkdir -p /etc/xdg/menus/ && echo "<Menu/>" > /etc/xdg/menus/kde-applications.menu

# This is meant to be extended so we keep the user as root to ease installing packages in child images
#USER ${USER}
EXPOSE ${PORT}
WORKDIR ${WORKSPACE}
CMD xpra start --bind-tcp=${INTERFACE} --html=on --start-child="${COMMAND}" --exit-with-children --daemon=no --xvfb="${FRAMEBUFFER}" --pulseaudio=no --speaker=off --notifications=no --bell=no --mdns=no --webcam=no --sharing=${SHARING} --clipboard=yes --clipboard-direction=both --ssl=off

