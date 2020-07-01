#gcc simple.c -I/home/tkwiatek/h2o/include/ -I/opt/local/include/ -I/home/tkwiatek/h2o/deps/yoml -L/opt/local/lib -lssl -lcrypto -L/home/tkwiatek/h2o -lh2o -lh2o-evloop -L/opt/local/lib -luv -lz -lpthread -v -o SIMPLE
# rsync --exclude h2o --exclude v2.3.0-beta1.tar.gz -r ../hxh2o/ mileena:/home/tkwiatek/hxh2o/
# ssh mileena "cd /home/tkwiatek/hxh2o/ && haxe build.hxml"


CONT=`docker ps | grep hxh2o_dev | cut -d' ' -f1`
if [ -z "$CONT" ]
then
      echo "no running hxh2o docker"
else
      echo "close docker"
      docker stop $CONT
fi
rm -rf hxh2o/build
rm -rf hxh2o/libs
mkdir bin
ID=`docker run -it -d -p 12345:80 --mount type=bind,source="$(pwd)",target=/src hxh2o_dev`
docker exec -it $ID /bin/bash -c 'echo "start" \
&& haxelib dev hxh2o /src/hxh2o \
&& ls /usr/lib/h2o/deps \
&& cd /src/hxh2o && haxe build.hxml \
&& mkdir libs \
&& cp /usr/lib/x86_64-linux-gnu/libuv.so.1 /src/hxh2o/libs/libuv.so.1 \
&& cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /src/hxh2o/libs/libssl.so.1.1 \
&& cp /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /src/hxh2o/libs/libcrypto.so.1.1 \
&& find / -name "libcrypto.so.1.1" \
&& echo "end"
'
docker stop $ID