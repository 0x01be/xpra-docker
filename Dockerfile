FROM alpine as build

RUN apk add --no-cache --virtual xpra-build-dependencies \
    subversion \
    build-base \
    pkgconfig \
    libx11-dev \
    libxrandr-dev \
    libxtst-dev \
    libxkbfile-dev \
    libxcomposite-dev \
    libxdamage-dev \
    gtk+3.0-dev \
    python3-dev \
    py3-pip \
    py3-cairo-dev \
    py3-gobject3-dev \
    gobject-introspection-dev \
    cython \
    xorg-server \
    gstreamer-dev \
    alsa-lib-dev \
    ffmpeg-dev \
    jpeg-dev \
    zlib-dev \
    lz4-dev \
    lzo-dev \
    brotli-dev \
    x264-dev \
    libvpx-dev \
    npm

RUN npm install -g uglify-js

RUN svn co https://xpra.org/svn/Xpra/trunk /xpra

WORKDIR /xpra/src/

RUN python3 ./setup.py --help

RUN python3 ./setup.py install \
    --home=/opt/xpra/ \
    --with-enc_x264 \
    --with-vpx \
    --with-enc_ffmpeg \
    --with-jpeg_encoder \
    --with-jpeg_decoder

