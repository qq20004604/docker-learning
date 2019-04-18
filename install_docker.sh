#!/usr/bin/env bash
echo "卸载老版本 Docker"
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine

echo "【2】安装依赖包"
sudo yum install -y yum-utils \
	device-mapper-persistent-data \
  	lvm2

echo "【3】添加源"
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

echo "【4】安装Docker CE版"
sudo yum install docker-ce docker-ce-cli containerd.io

echo "【5】查看Docker版本"
docker version

echo "【6】启动Docker"
sudo service docker start

echo "【7】显示Docker 镜像，如果没显示"
docker images