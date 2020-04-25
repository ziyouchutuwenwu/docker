basepath=$(cd `dirname $0`; pwd)

check_docker_network(){
  docker network ls | grep isolated_network > /dev/null
  if [ $? -ne 0 ]; then
    echo "no network, let me create!"
    docker network create --driver bridge isolated_network
  else
    echo "network already created!"
  fi
}
check_docker_network

# --user $(id -u):$(id -g)
# sudo chown -hR $(id -u):$(id -g) ~/projects/docker

docker run --rm -d --network=isolated_network --name apache_php -p 8888:80 -v ~/projects/docker/web_root:/app -e XDEBUG_REMOTE_AUTOSTART=1 -e XDEBUG_REMOTE_ENABLE=1 webdevops/php-apache-dev:7.3

docker run --rm -d --network=isolated_network --name nginx -p 7777:7777 -v ~/projects/docker/web_root:/web_root -v $basepath"/conf/nginx/":/etc/nginx/conf.d/ nginx:alpine
# docker exec -it nginx /bin/sh

docker run --rm -d --network=isolated_network --name redis_server -p 6379:6379 redis

# docker run --rm -d --network=isolated_network --name mysql -p 4407:3306 -v ~/projects/docker/db/mysql:/var/lib/mysql -v $basepath"/conf/mysql/my.cnf":/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ALLOW_EMPTY_PASSWORD=true --privileged=true mysql:8.0
docker run --rm -d --network=isolated_network --name mysql -p 4407:3306 -v ~/projects/docker/db/mysql:/var/lib/mysql -v $basepath"/conf/mysql/my.cnf":/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ALLOW_EMPTY_PASSWORD=true --privileged=true mysql:8.0

docker run --rm -d --network=isolated_network --name pgsql -p 6543:5432 -v ~/projects/docker/db/pgsql:/var/lib/postgresql/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres

docker run --rm -d --network=isolated_network --name nfs_server -v ~/projects/docker/nfs/:/nfs -e NFS_EXPORT_DIR_1=/nfs -e NFS_EXPORT_DOMAIN_1=\* -e NFS_EXPORT_OPTIONS_1=rw,insecure,no_subtree_check,no_root_squash,fsid=1 -p 111:111 -p 111:111/udp -p 2049:2049 -p 2049:2049/udp -p 32765:32765 -p 32765:32765/udp -p 32766:32766 -p 32766:32766/udp -p 32767:32767 -p 32767:32767/udp --privileged=true fuzzle/docker-nfs-server:latest

docker run --rm -d -it --network=isolated_network --name=tftpd -p 69:69/udp -v ~/projects/docker/tftp:/srv/tftp hkarhani/tftpd

# -u "mmc;mmc" -s "shared;/mount/;yes;no;no;all;none"
docker run --rm -d --network=isolated_network --name samba -v ~/projects/docker/smb/:/mount -p 139:139 -p 445:445 dperson/samba -p -s "shared;/mount/;yes;no;yes;all;none"

# for erlang build for arm
docker run -it -d --rm --name arm_erlang --network host --rm -v ~/projects/erlang/:/usr/src arm32v7/erlang