#!/usr/bin/env bash
appfilename="app"
mysqldata="mysqldata"
docker image build -t docker-demo-02-mysql:0.0.1 ./app
if [ ! -d $mysqldata ]; then
  mkdir "$mysqldata"
fi

# 先用原本镜像生成容器 mysql-v0，mysql的root密码是1234567890
echo "【1】先用原本镜像生成容器，初始化不需要密码（后续添加），并进行持久化配置"
echo "$PWD/$mysqldata"
docker run --name mysql-demo -d -v "$PWD/$mysqldata":/var/lib/mysql -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:5.6
#docker run --name mysql-demo -d -v "$PWD/$mysqldata":/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234567890 mysql:5.6

# 然后把 app 文件拷贝到容器里面
echo "【2】然后把 app 文件拷贝到容器里面"
docker cp "$PWD/$appfilename" mysql-demo:/

#echo "【3】执行容器内的初始化脚本"
docker exec mysql-demo sh /app/init.sh