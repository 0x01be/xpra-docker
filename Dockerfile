FROM alpine as builder

RUN apk add --no-cache --virtual xpra-build-dependencies \
    subversion \
    build-base \
    python3-dev \
    cython \
    pkgconfig \
    libx11-dev \
    libxrandr-dev \
    libxtst-dev \
    libxkbfile-dev \
    libxcomposite-dev \
    libxdamage-dev \
    gtk+3.0-dev \
    py3-pip \
    gobject-introspection-dev \
    py3-gobject3-dev \
    xorg-server 

RUN pip install pycairo

RUN svn co https://xpra.org/svn/Xpra/trunk /xpra

WORKDIR /xpra/src/

RUN python3 ./setup.py install --home=/opt/xpra/

FROM alpine

RUN apk add --no-cache --virtual xpra-runtime-dependencies \
    python3 \
    py3-gobject3 \
    py3-rencode \
    py3-pillow \
    py3-cairo \
    py3-xdg \
    dbus-x11 \
    gstreamer \
    xvfb \
    gtk+3.0

COPY --from=builder /opt/xpra/bin/ /usr/bin/
COPY --from=builder /opt/xpra/lib/python/ /usr/lib/python3.8/site-packages/
COPY --from=builder /opt/xpra/share/xpra/ /usr/share/xpra/
COPY --from=builder /opt/xpra/etc/xpra/ /etc/xpra/
COPY --from=builder /opt/xpra/etc/X11/xorg.conf.d/ /etc/X11/xorg.conf.d/
COPY --from=builder /opt/xpra/etc/dbus-1/system.d/ /etc/dbus-1/system.d/

RUN mkdir -p /run/user/0/

