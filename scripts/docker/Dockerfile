FROM haxe:latest

RUN apt-get update \
    && apt-get install -y curl git mc \
    && apt-get install -y python3 python2 \
    && apt-get install -y make g++ sudo build-essential awscli \
    && apt-get install -y gnupg zip \
    && apt-get install -y wget default-jre rsync \
    && apt-get install -y ant inotify-tools \
    && curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - \
    && apt-get install -y nodejs \
    && npm i -g yarn \
    && haxelib setup ~/haxelib

RUN haxelib install dox \
    && haxelib git hxparse https://github.com/Simn/hxparse master src \
    && haxelib git hxtemplo https://github.com/Simn/hxtemplo master src \
    && haxelib install hxargs \
    && haxelib install markdown \
    && haxelib install nme  \
    && haxelib install svg \
    && haxelib install promhx \
    && haxelib install actuate \
    && haxelib install hxcpp \
    && npm install -g remarkable \
    && npm install -g javascript-obfuscator \
    && npm install -g uglifyjs \
    && npm install -g live-server

RUN apt-get update \
    && apt-get install -y libssl-dev \
    && cd ~ \
    && rm -rf openssl
    && git clone https://github.com/openssl/openssl.git \
    && cd openssl \
    && ./config -Wl,--enable-new-dtags,-rpath,'$(LIBRPATH)' \
    && make \
    && make install \
    && openssl version -a

RUN apt-get update \
    && apt-get install -y cmake zlib1g zlib1g-dev libuv1 libuv1-dev libh2o-evloop-dev protobuf-compiler \
    && cd ~ \
    && rm -rf h2o
    && git clone https://github.com/h2o/h2o.git \
    && cd h2o \
    && cmake -DWITH_BUNDLED_SSL=on \
    && make \
    && make install \
    && make libh2o 

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
