#!/usr/bin/env bash
# 如果需要使用其他镜像，记得自行修改脚本
# 修改映射到本机的端口也一样

appfilename="app"
mysqldatafilename="mysqldata"
imagename="docker-demo-02-mysql:0.0.1"
containername="mysql-demo"

# 建立持久化文件夹
if [[ ! -d ${mysqldatafilename} ]]; then
  mkdir "$mysqldatafilename"
fi

echo "【1】下载 mysql:5.6.43 版本 image"
#docker pull mysql:5.6.43
echo "下载完成或无需下载"

echo "【2】先用原本镜像生成容器，初始化不需要密码（后续添加），并进行持久化配置"
echo "$PWD/$mysqldatafilename"
docker run --name "$containername" -v "$PWD/$mysqldatafilename":/var/lib/mysql -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d mysql:5.6.43 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

# 如果自己手动执行的话，下面这行脚本可以在创建容器时即添加账号密码
#docker run --name mysql-demo -d -v "$PWD/$mysqldatafilename":/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234567890 mysql:5.6.43

# 然后把 app 文件拷贝到容器里面
echo "【3】然后把 app 文件拷贝到容器里面"
docker cp "$PWD/$appfilename" "$containername":/

echo "【4】执行容器内的初始化脚本"
docker exec "$containername" sh "/$appfilename/init.sh"
