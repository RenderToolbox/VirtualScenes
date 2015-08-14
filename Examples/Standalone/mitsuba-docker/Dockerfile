FROM ubuntu:14.04

MAINTAINER Ben Heasly <benjamin.heasly@gmail.com>

### system dependencies
RUN apt-get update \
    && apt-get install -y\
    build-essential \
    git \
    libboost-all-dev \
    libeigen3-dev \
    libfftw3-dev \
    libglew-dev \
    libglewmx-dev \
    libilmbase-dev \
    libjpeg8-dev \
    libjpeg-dev \
    libopenexr-dev \
    libpcrecpp0 \
    libpng12-dev \
    libxerces-c3.1 \
    libxerces-c-dev \
    libx11-dev \
    libxxf86vm-dev \
    mercurial \
    mercurial-common \
    python-pip \
    qt4-dev-tools \
    scons \
    unzip \
    wget \
    x11-xserver-utils \
    x11proto-xf86vidmode-dev \
    x11vnc \
    xpra \
    xserver-xorg-video-dummy \
    zlib1g-dev \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove

### Amazon command line tool
RUN pip install awscli

### extra Mitsuba dependencies
RUN wget http://www.mitsuba-renderer.org/releases/current/trusty/collada-dom-dev_2.4.0-1_amd64.deb \
    && wget http://www.mitsuba-renderer.org/releases/current/trusty/collada-dom_2.4.0-1_amd64.deb \
    && dpkg --install collada-dom*.deb

### set up headless X server
ADD xorg.conf /etc/X11/xorg.conf
RUN echo 'xpra start :0' > /etc/bash.bashrc
ENV DISPLAY :0

### run as a regular user
RUN groupadd -r rtb \
    && useradd -r -m -g rtb rtb
USER rtb
WORKDIR /home/rtb

### get Mitsuba source
RUN mkdir /home/rtb/mitsuba-src
WORKDIR /home/rtb/mitsuba-src
RUN hg clone --insecure https://www.mitsuba-renderer.org/hg/mitsuba

### build and install RBG Mitsuba
WORKDIR /home/rtb/mitsuba-src/mitsuba
RUN cp build/config-linux-gcc.py config.py \
    && scons \
    && mkdir -p /home/rtb/mitsuba-rgb \
    && cp -r dist/* /home/rtb/mitsuba-rgb

### edit mitsuba source and config for 31 spectrum bands in 395-705nm
RUN sed 's/SAMPLES=[0-9]*/SAMPLES=31/' build/config-linux-gcc.py > config.py
RUN sed -e 's/SPECTRUM_MIN_WAVELENGTH[ ^I]*[0-9]*$/SPECTRUM_MIN_WAVELENGTH   395/' \
    -e 's/SPECTRUM_MAX_WAVELENGTH[ ^I]*[0-9]*$/SPECTRUM_MAX_WAVELENGTH   705/' \
    --in-place include/mitsuba/core/spectrum.h

### build and install multispectral Mitsuba
RUN scons \
    && mkdir -p /home/rtb/mitsuba-multi \
    && cp -r dist/* /home/rtb/mitsuba-multi

### get runtime used by Matlab compiled executables
WORKDIR /home/rtb/
USER root
RUN wget http://www.mathworks.com/supportfiles/downloads/R2015a/deployment_files/R2015a/installers/glnxa64/MCR_R2015a_glnxa64_installer.zip \
    && unzip MCR_R2015a_glnxa64_installer.zip -d matlab-runtime \
    && rm MCR_R2015a_glnxa64_installer.zip \
    && cd matlab-runtime \
    && mkdir -p /usr/local/MATLAB/MATLAB_Runtime/v85 \
    && ./install -mode silent -agreeToLicense yes \
    && cd .. \
    && rm -r matlab-runtime

### get our Matlab executable from the local context
WORKDIR /home/rtb/
USER rtb
ADD LinuxRecipeExecutor.zip LinuxRecipeExecutor.zip
RUN unzip LinuxRecipeExecutor.zip -d recipe-executor \
    && rm LinuxRecipeExecutor.zip

### get our script to launch our Matlab executable from local context
ADD run-recipe-executor run-recipe-executor

