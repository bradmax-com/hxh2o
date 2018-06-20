sudo apt-get install libuv1

wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz
tar xzvf openssl-1.1.0f.tar.gz
cd openssl-1.1.0f
./config -Wl,--enable-new-dtags,-rpath,'$(LIBRPATH)'
make
sudo make install

openssl version -a



 1466  sudo apt-get install libuv1.dev
 1582  find / -name libuv.a
 1822  PKG_CONFIG_PATH=/usr/local/libuv-1.4/lib/pkgconfig:/usr/local/openssl-1.0.2a/lib/pkgconfig cmake .