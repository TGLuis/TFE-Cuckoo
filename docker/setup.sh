#!/bin/bash

tcpdumpInstalled=$(dpkg -l | grep tcpdump)
if [[ $tcpdumpInstalled == "" ]]; then
    sudo apt-get install -y tcpdump
fi

apparmorInstalled=$(dpkg -l | grep apparmor-utils)
if [[ $apparmorInstalled == "" ]]; then
    sudo apt-get install -y apparmor-utils
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
fi

apparmorResult=$(sudo aa-status | grep /usr/sbin/tcpdump)
if [[ $apparmorResult == *"/usr/sbin/tcpdump"* ]]; then
    sudo aa-disable /usr/sbin/tcpdump
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build DIR -t cuckoodocker


