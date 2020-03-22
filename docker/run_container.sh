#!/bin/bash

isUp=$(docker ps -a --filter "name=cuckooVB" | grep cuckooVB)
if [[ $isUp == *"Exited"* ]]; then
    docker start cuckooVB
fi
#cuckoo1started=$(docker exec -it cuckooVB VBoxManage list runningvms)
#if [[ $cuckoo1started == "" ]]; then
    #docker exec -it cuckooVB VBoxManage startvm cuckoo1 --type headless
    #docker exec -it cuckooVB cat /root/.config/VirtualBox/VBoxSVC.log
#fi

docker exec -it cuckooVB /bin/bash

