docker build -t hxh2o_dist -f- . <<EOF
FROM ubuntu:18.04
COPY hxh2o/libs/libuv.so.1 /usr/lib/x86_64-linux-gnu/libuv.so.1
COPY hxh2o/libs/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/libssl.so.1.1
COPY hxh2o/libs/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1
COPY hxh2o/build/Main /Main
EOF