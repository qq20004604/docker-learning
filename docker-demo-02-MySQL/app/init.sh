#!/usr/bin/env bash
# 等待 MySQL 启动完毕
echo '当前 mysql 服务状态：'
echo `service mysql status`
echo "1.等待15秒，确保mysql已经启动了，不然 SQL 可能无法顺利导入"
sleep 15
echo '当前 mysql 服务状态：'
echo `service mysql status`

# 导入预创建库表的sql文件
echo "2.开始导入数据"
mysql < /app/data.sql
echo '3.导入数据完毕.....并等待3秒.....'
sleep 3

# 由于最开始设置mysql为免密登陆，为了安全，在此设置mysql密码，并进行权限配置
echo '4.开始进行权限配置.....'
# 导入修改mysql权限设置的文件
mysql < /app/privileges.sql
echo '5.修改密码完毕.....'

echo '----------------------------------------------------------'
echo "mysql容器启动完毕。如果导入数据时，显示 Can't connect to local MySQL server through socket，则说明导入失败。容器外手动执行命令【docker exec mysql-demo sh /app/init.sh】即可"
echo '----------------------------------------------------------'
