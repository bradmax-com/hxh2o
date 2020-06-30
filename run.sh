
CONT=`docker ps | grep hxh2o_dist | cut -d' ' -f1`
if [ -z "$CONT" ]
then
      echo "no running hxh2o docker"
else
      echo "close docker"
      docker stop $CONT
fi
ID=`docker run -it -d -p 12345:12345 hxh2o_dist`
# docker exec -it $ID /bin/bash -c './Main'
# docker stop $ID