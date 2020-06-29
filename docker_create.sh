# create a directory to work in
mkdir hc_docker
cp install_haxe.sh hc_docker/install_haxe.sh
cd hc_docker

docker build -t hxh2o_dev -f- . <<EOF
FROM ubuntu:18.04

# --------------
#  libs install
# --------------
RUN apt-get -y update && apt-get -y upgrade && apt-get -y --no-install-recommends install \
wget \
build-essential \
libuv1 \
libuv1-dev \
git \
cmake \
zlibc \
zlib1g \
zlib1g-dev \
protobuf-compiler \
default-jre

# ----------------
#  haxe neko+haxe
# ----------------
COPY install_haxe.sh install_haxe.sh
RUN ./install_haxe.sh y
ENV HAXE_STD_PATH="/usr/lib/haxe/std"
ENV HAXE_HOME="/usr/lib/haxe"
ENV PATH=$PATH":"$HAXE_HOME
ENV PATH=$PATH":"$HAXE_STD_PATH

# -------------------
#  haxe libs install
# -------------------
RUN haxelib install hxcpp
# RUN haxelib git hxh2o https://github.com/bradmax-com/hxh2o.git feture/new-router

# ---------
#  openssl
# ---------
WORKDIR /usr/lib/haxe/lib/hxh2o
RUN wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
RUN tar xzvf OpenSSL_1_1_1d.tar.gz
RUN rm OpenSSL_1_1_1d.tar.gz
RUN mv openssl-OpenSSL_1_1_1d openssl
WORKDIR /usr/lib/haxe/lib/hxh2o/openssl
RUN ./config -Wl,--enable-new-dtags,-rpath,'$(LIBRPATH)'
RUN make
RUN make install

# -----
#  h2o
# -----
WORKDIR /usr/lib/haxe/lib/hxh2o
RUN wget https://github.com/h2o/h2o/archive/v2.3.0-beta2.tar.gz
RUN tar zxvf v2.3.0-beta2.tar.gz
RUN rm v2.3.0-beta2.tar.gz
RUN mv h2o-2.3.0-beta2 h2o

WORKDIR /usr/lib/haxe/lib/hxh2o/h2o/
RUN cmake -DWITH_BUNDLED_SSL=on .
RUN make
RUN make install
RUN make libh2o
WORKDIR /
EOF