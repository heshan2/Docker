FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

# Installing dependencies
RUN apt-get -qq -y update && apt-get -qq -y upgrade && apt-get -qq install -y software-properties-common \
        && add-apt-repository ppa:rock-core/qt4 \
        && apt-get -qq install -y tzdata python3 python3-pip \
        unzip p7zip-full mediainfo p7zip-rar aria2 wget curl \
        pv jq ffmpeg locales python3-lxml xz-utils neofetch \
        git g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig

# Installing MegaSDK Python binding
ENV MEGA_SDK_VERSION="3.9.2"
RUN git clone https://github.com/meganz/sdk.git sdk && cd sdk \
    && git checkout v$MEGA_SDK_VERSION \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl \
    && cd ~

# Installing MirrorBot dependencies
RUN curl -sLo /usr/local/bin/extract https://raw.githubusercontent.com/heshan2/torrent-mirror/master/extract \
    && curl -sLo /usr/local/bin/pextract https://raw.githubusercontent.com/heshan2/torrent-mirror/master/pextract \
    && chmod +x /usr/local/bin/extract /usr/local/bin/pextract \
    && wget https://raw.githubusercontent.com/heshan2/torrent-mirror/master/requirements.txt \
    && pip3 install --no-cache-dir -r requirements.txt \
    && rm requirements.txt

# Cleanup environment
RUN apt-get -qq -y purge autoconf automake g++ gcc libtool m4 make software-properties-common swig \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /var/tmp/* /tmp/* \
    && apt-get -qq -y update && apt-get -qq -y upgrade && apt-get -qq -y autoremove && apt-get -qq -y autoclean

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
