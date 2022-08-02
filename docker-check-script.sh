
#!/bin/bash

containerstate=$(docker inspect backend --format='{{.State.Status}}' 2> /dev/null)
if [ ! -z $containerstate ]
then
        if [ $containerstate = "running" ]
        then
            docker stop backend && docker rm backend
        fi
fi
    sudo docker run -d --name backend -p 9966:9966 springcommunity/spring-petclinic-rest