#!/bin/bash

# -v /dev/vboxdrvu:/dev/vboxdrvu
# -v /dev/vboxnetctl:/dev/vboxnetctl


exists=$(docker ps -a --filter "name=cuckooVB" | grep cuckooVB)
if [[ $exists == "" ]]; then
    
    path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    docker create --name cuckooVB -i \
        -v "$path/../cuckoo":/root/.cuckoo \
        -v "$path/../malwares":/home/cuckoo/malwares \
        -v "$path/../vms":/home/cuckoo/vms \
        -v "$path/../monitor":/home/cuckoo/mymonitor \
        -v /proc:/proc \
        -v /dev/vboxdrv:/dev/vboxdrv  \
        --network=host \
        --privileged \
        cuckoodocker:latest

    docker start cuckooVB
    # import community and create symbolic link if not done (necessary for hooks)
    docker exec -it cuckooVB cuckoo community --file master.tar.gz
    
    isok=$(docker exec -it cuckooVB test -f "/root/.cuckoo/monitor/mymonitor" && echo "ok")
    if [[ $isok != "ok" ]]; then
        docker exec -it cuckooVB ln -sd "/home/cuckoo/mymonitor/bin" "/root/.cuckoo/monitor/mymonitor"
    fi

    # install the extension pack and import the vm
    docker exec -it cuckooVB VBoxManage extpack install /home/cuckoo/Oracle_VM_VirtualBox_Extension_Pack-$(dpkg -s virtualbox-5.2 | grep '^Version: ' | sed -e 's/Version: \([0-9\.]*\)\-.*/\1/').vbox-extpack --accept-license=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb
    docker exec -it cuckooVB VBoxManage import /home/cuckoo/vms/cuckoo1.ova
    sleep 1s

    # make snapshot of the vm
    docker exec -it cuckooVB VBoxManage startvm cuckoo1 --type headless
    docker exec -it cuckooVB VBoxManage snapshot cuckoo1 take snapshot1
    docker exec -it cuckooVB VBoxManage controlvm cuckoo1 poweroff soft

else
    echo "Container already created"
fi

