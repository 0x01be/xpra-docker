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
    xorg-server \
    gstreamer-dev \
    alsa-lib-dev \
    ffmpeg-dev \
    jpeg-dev \
    zlib-dev \
    lz4-dev \
    x264-dev \
    libvpx-dev

RUN pip install pycairo

RUN svn co https://xpra.org/svn/Xpra/trunk /xpra

WORKDIR /xpra/src/

RUN python3 ./setup.py install \
    --home=/opt/xpra/ \
    --with-enc_x264 \
    --with-vpx \
    --with-enc_ffmpeg \
    --with-jpeg_encoder \
    --with-jpeg_decoder

