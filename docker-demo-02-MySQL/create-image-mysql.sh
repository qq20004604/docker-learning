#!/usr/bin/env bash
mysqldata="mysqldata"
docker image build -t docker-demo-02-mysql:0.0.1 ./app
if [ ! -d $mysqldata ]; then
  mkdir "$mysqldata"
fi
work_path=$(dirname $(readlink -f $0))
work_path="$work_path/$mysqldata/"
echo $work_path
#-v /usr/local/src/Docker/docker-demo-02-MySQL/"$mysqldata":/var/lib/mysql
# 这次进行挂载
docker run --name mysql-demo -v /usr/local/src/Docker/docker-demo-02-MySQL/"$mysqldata":/var/lib/mysql -p 3306:3306 docker-demo-02-mysql:0.0.1
docker run --name mysql-demo -v "$PWD/mysqldata":/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234567890 mysql:5.6
#sudo docker run --name mysql-demo -v /usr/local/src/Docker/docker-demo-02-MySQL/"$mysqldata":/var/lib/mysql -p 3306:3306 docker-demo-02-mysql:0.0.1
#docker run --name mysql-demo -dit -v /usr/local/src/Docker/docker-demo-02-MySQL/"$mysqldata":/var/lib/mysql -p 3306:3306 docker-demo-02-mysql:0.0.1 /bin/bash