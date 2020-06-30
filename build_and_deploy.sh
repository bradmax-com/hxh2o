./build.sh
./docker_create_run.sh
docker save hxh2o_dist -o hxh2o_dist.tgz
scp hxh2o_dist.tgz $1:/home/ubuntu