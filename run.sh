
CONT=`docker ps | grep hxh2o_dist | cut -d' ' -f1`
if [ -z "$CONT" ]
then
      echo "no running hxh2o_dist docker"
else
      echo "close docker"
      docker stop $CONT
fi
docker rm hxh2o_dist
ID=`docker run -it -d -p 12345:12345 --name hxh2o_dist hxh2o_dist`
docker logs -f hxh2o_dist
# docker exec -it $ID /bin/bash -c './Main'
# docker stop $ID