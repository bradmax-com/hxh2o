#gcc simple.c -I/home/tkwiatek/h2o/include/ -I/opt/local/include/ -I/home/tkwiatek/h2o/deps/yoml -L/opt/local/lib -lssl -lcrypto -L/home/tkwiatek/h2o -lh2o -lh2o-evloop -L/opt/local/lib -luv -lz -lpthread -v -o SIMPLE




rsync --exclude h2o --exclude v2.3.0-beta1.tar.gz -r ../hxh2o/ mileena:/home/tkwiatek/hxh2o/
ssh mileena "cd /home/tkwiatek/hxh2o/ && haxe build.hxml"