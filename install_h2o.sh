sudo apt-get install libssl-dev
sudo rm -r h2o
rm v2.3.0-beta1.tar.gz
wget https://github.com/h2o/h2o/archive/v2.3.0-beta1.tar.gz
tar zxvf v2.3.0-beta1.tar.gz
mv h2o-2.3.0-beta1 h2o
cd h2o
cmake -DWITH_BUNDLED_SSL=on .
make
sudo make install
make libh2o