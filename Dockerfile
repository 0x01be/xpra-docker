FROM 0x01be/xpra:build as build

FROM alpine

RUN apk add --no-cache --virtual xpra-runtime-dependencies \
    python3 \
    py3-gobject3 \
    py3-rencode \
    py3-pillow \
    py3-cairo \
    py3-xdg \
    py3-dbus \
    py3-requests \
    dbus-x11 \
    gstreamer \
    xvfb \
    gtk+3.0 \
    gnome-icon-theme \
    ttf-freefont \
    ffmpeg \
    jpeg \
    x264 \
    libvpx \
    zlib \
    lzo \
    lz4 \
    lz4-static \
    brotli \
    brotli-static

COPY --from=build /opt/xpra/bin/ /usr/bin/
COPY --from=build /opt/xpra/lib/python/ /usr/lib/python3.8/site-packages/
COPY --from=build /opt/xpra/share/xpra/ /usr/share/xpra/
COPY --from=build /opt/xpra/etc/xpra/ /etc/xpra/
COPY --from=build /opt/xpra/etc/X11/xorg.conf.d/ /etc/X11/xorg.conf.d/
COPY --from=build /opt/xpra/etc/dbus-1/system.d/ /etc/dbus-1/system.d/

ENV UID 1000
ENV USER xpra
ENV WORKSPACE /home/xpra

RUN adduser -D -u ${UID} ${USER} &&\
    mkdir -p /run/user/${UID}/${USER} &&\
    mkdir -p /run/${USER} &&\
    mkdir -p ${WORKSPACE} &&\
    chown -R ${USER}:${USER} /run/user/${UID}/${USER} &&\
    chown -R ${USER}:${USER} /run/${USER} &&\
    chown -R ${USER}:${USER} ${WORKSPACE} &&\
    mkdir -p /tmp/.X11-unix &&\
    chmod 1777 /tmp/.X11-unix

ENV PORT 10000

# This image is meant to be extended so we keep the user as root to ease installing packages in descendents
#USER ${USER}
ENV COMMAND 'echo "Extend this image and set COMMAND"'
WORKDIR ${WORKSPACE}
EXPOSE ${PORT}

ENV SCREEN "1280x720x24+32"
ENV FRAMEBUFFER "/usr/bin/Xvfb +extension GLX +extension RANDR +extension RENDER +extension Composite -screen 0 ${SCREEN} -nolisten tcp -noreset"
ENV INTERFACE "0.0.0.0:${PORT}"

CMD xpra start --bind-tcp=${INTERFACE} --html=on --start-child=${COMMAND} --exit-with-children --daemon=no --xvfb="${FRAMEBUFFER}" --pulseaudio=no --notifications=no --bell=no --mdns=no

