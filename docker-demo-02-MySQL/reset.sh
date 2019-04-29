#!/usr/bin/env bash
docker container stop mysql-demo
docker container rm mysql-demo
docker container stop mysql-v0
docker container rm mysql-v0
docker image rm mysql-demo:v1
docker image rm docker-demo-02-mysql:0.0.1
rm -rf mysqldata
rm -rf log.log
