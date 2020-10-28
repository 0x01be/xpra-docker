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
    lz4 \
    alsa-lib

COPY --from=build /opt/xpra/bin/ /usr/bin/
COPY --from=build /opt/xpra/lib/python/ /usr/lib/python3.8/site-packages/
COPY --from=build /opt/xpra/share/xpra/ /usr/share/xpra/
COPY --from=build /opt/xpra/etc/xpra/ /etc/xpra/
COPY --from=build /opt/xpra/etc/X11/xorg.conf.d/ /etc/X11/xorg.conf.d/
COPY --from=build /opt/xpra/etc/dbus-1/system.d/ /etc/dbus-1/system.d/

ENV WORKSPACE /home/xpra
ENV COMMAND 'echo "Extend this image and set COMMAND"'

ENV GUID 1000
ENV USER xpra
RUN adduser -D -u ${GUID} ${USER}
RUN mkdir -p /run/user/${GUID}/${USER}
RUN mkdir -p /run/${USER}
RUN mkdir -p ${WORKSPACE}
RUN chown -R ${USER}:${USER} /run/user/${GUID}/${USER}
RUN chown -R ${USER}:${USER} /run/${USER}
RUN chown -R ${USER}:${USER} ${WORKSPACE}

ENV PORT 10000

USER ${USER}
WORKDIR ${WORKSPACE}
EXPOSE ${PORT}

ENV SCREEN "1280x720x24+32"
CMD ["/usr/bin/xpra", "start" ,"--bind-tcp=0.0.0.0:${PORT}",  "--html=on", "--start-child=${COMMAND}", "--exit-with-children" , "--daemon=no", "--xvfb='/usr/bin/Xvfb +extension  Composite -screen 0 ${SCREEN} -nolisten tcp -noreset'", "--pulseaudio=no", "--notifications=no", "--bell=no", "--mdns=no"]

