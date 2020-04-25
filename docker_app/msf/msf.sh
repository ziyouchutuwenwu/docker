#! /bin/env bash

basepath=$(cd `dirname $0`; pwd)

docker kill msf > /dev/null 2>&1
docker run --rm -it --name msf --network host -v $basepath"/conf":/home/msf/init/ metasploitframework/metasploit-framework /usr/src/metasploit-framework/msfconsole -r /home/msf/init/db_init.rc