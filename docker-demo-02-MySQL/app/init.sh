#!/usr/bin/env bash
# 使进程休眠3秒
sleep 3
echo "1.等待10秒，确保mysql已经启动了"
sleep 10

echo `service mysql status`

echo "2.开始导入数据"

# 导入sql文件
mysql < /app/data.sql
echo '3.导入数据完毕....'
sleep 3
echo `service mysql status`

# 由于最开始设置mysql为免密登陆，为了安全，在此设置mysql密码
echo '4.开始修改密码....'
# 导入修改mysql权限设置的文件
mysql < /app/privileges.sql
echo '5.修改密码完毕....'

#sleep 3
echo `service mysql status`
echo "mysql容器启动完毕。如果导入数据时，显示 Can't connect to local MySQL server through socket，则说明导入失败。容器外手动执行命令【docker exec mysql-demo sh /app/init.sh】即可"