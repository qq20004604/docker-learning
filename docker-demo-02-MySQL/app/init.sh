#!/usr/bin/env bash
echo '------ init.sh 执行中------'
# 拷贝utf8配置文件
cp /app/mysql.cnf /etc/mysql/conf.d/
# 等待 MySQL 启动完毕
echo '当前 mysql 服务状态：'
echo `service mysql status`
echo "1.等待15秒，确保mysql已经启动了，不然 SQL 可能无法顺利导入"
# 我在centos7上并不需要跑下面这行代码，但是在mac上就必须跑（不然容器会自动停止），原因未知
# 另外，即使执行，有时候在mac上也会自动停止，很坑
# service mysql start
sleep 5
echo `service mysql status`
sleep 5
echo `service mysql status`
sleep 5
echo '当前 mysql 服务状态：'
echo `service mysql status`

echo '2、设置 UTF8 命令中......'
echo '查看当前是否已经被转换为utf8'
mysql < /app/utf8.sql

# 导入预创建库表的sql文件
echo "3.开始导入数据"
mysql < /app/data.sql
echo '4.导入数据完毕.....并等待3秒.....'
sleep 3

# 由于最开始设置mysql为免密登陆，为了安全，在此设置mysql密码，并进行权限配置
echo '5.开始进行权限配置.....'
# 导入修改mysql权限设置的文件
mysql < /app/privileges.sql
echo '6.修改密码完毕.....'

echo '----------------------------------------------------------'
echo "mysql容器启动完毕。如果导入数据时，显示 Can't connect to local MySQL server through socket，则说明导入失败。容器外手动执行命令【docker exec mysql-demo sh /app/init.sh】即可"
echo '----------------------------------------------------------'
echo '------ init.sh 执行完毕------'