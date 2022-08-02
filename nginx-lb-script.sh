#!/bin/bash

containerstate=$(docker inspect nginx --format='{{.State.Status}}' 2> /dev/null)
if [ ! -z $containerstate ]
then
        if [ $containerstate = "running" ]
        then
            docker stop nginx && docker rm nginx
        fi
fi
    docker run -d -p 80:80 --mount type=bind,source=$(pwd)/nginx.conf,target=/etc/nginx/nginx.conf --name nginx nginx