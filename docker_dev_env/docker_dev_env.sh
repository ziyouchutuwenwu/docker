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

docker run --rm -d --net isolated_network --name apache-php -p 8888:80 -v ~/projects/docker/web_root:/app -e XDEBUG_REMOTE_AUTOSTART=1 -e XDEBUG_REMOTE_ENABLE=1 webdevops/php-apache-dev:alpine

docker run --rm -d --net isolated_network --name nginx -p 7895:7895 -v ~/projects/docker/web_root:/web_root -v $basepath"/conf/nginx/nginx.conf":/etc/nginx/nginx.conf -v $basepath"/conf/nginx/conf.d/":/etc/nginx/conf.d/ nginx:alpine
# docker exec -it nginx /bin/sh

docker run --rm -d --net isolated_network --name redis-server -p 6379:6379 redis

docker run --rm -d --net isolated_network --name mysql -p 4407:3306 -v ~/projects/docker/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ALLOW_EMPTY_PASSWORD=true --privileged=true mysql:8.0

docker run --rm -d --net isolated_network --name pgsql -p 6543:5432 -v ~/projects/docker/pgsql:/var/lib/postgresql/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres

# k8s的nfs存储依赖 nfs-common, 依赖rpcbind，这个和k8s的调试冲突
# mount -t nfs -o nolock 192.168.88.234:/nfs ./remote_nfs
docker run --rm -d --net isolated_network --name nfs-server -v ~/projects/docker/nfs/:/nfs -e NFS_EXPORT_DIR_1=/nfs -e NFS_EXPORT_DOMAIN_1=\* -e NFS_EXPORT_OPTIONS_1=rw,insecure,no_subtree_check,no_root_squash,fsid=1 -p 111:111 -p 111:111/udp -p 2049:2049 -p 2049:2049/udp -p 32765:32765 -p 32765:32765/udp -p 32766:32766 -p 32766:32766/udp -p 32767:32767 -p 32767:32767/udp --privileged=true fuzzle/docker-nfs-server:latest

docker run --rm -d -it --net isolated_network --name=tftpd -p 69:69/udp -v ~/projects/docker/tftp:/srv/tftp hkarhani/tftpd

# -u "mmc;mmc" -s "shared;/mount/;yes;no;no;all;none"
# 共享目录为 \\ip\shared
docker run --rm -d --net isolated_network --name samba -v ~/projects/docker/smb/:/mount -p 139:139 -p 445:445 dperson/samba -p -s "shared;/mount/;yes;no;yes;all;none"

# es
docker run --rm -d --net isolated_network --name es -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.12.1