# build wine
FROM i386/ubuntu:18.04 as winebuild
LABEL maintainer="kicsikrumpli@gmail.com"

# build:
# external X server at build time: --build-arg DISPLAY=host.docker.internal:0
# NB! do on host: xhost + 127.0.0.1

# enable source code repos and update: 
ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i '/deb-src/s/^# //' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y flex \
    bison \
    gcc \
    build-essential \
    xdotool \
    xvfb \
    && apt-get build-dep -y wine \
    && apt-get clean

# copy, unpack, build wine source
COPY wine-6.0.tar.xz /
RUN  mkdir -p /wine && cd /wine && tar -xf ../wine-6.0.tar.xz \
     && cd wine-6.0 && ./configure && make && make install \
     && cd / && rm -rf /wine

# default for X Virtual Frame Buffer
ARG DISPLAY=:1
ENV DISPLAY=${DISPLAY}
RUN echo "DISPLAY: ${DISPLAY}"

# winecfg
WORKDIR /root/.wine/drive_c
COPY python-3.7.9.exe .

COPY config.sh .
COPY winew.sh .
COPY entrypoint.sh .

RUN chmod +x config.sh winew.sh entrypoint.sh && ./config.sh

ENTRYPOINT [ "./entrypoint.sh" ]
