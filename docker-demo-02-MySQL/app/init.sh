#!/usr/bin/env bash
# 挂载外部绑定文件和内部绑定文件
sudo mount --bind /mysqldata /var/lib/mysql
# 查看mysql服务的状态，方便调试
echo `service mysql status`
echo '1.启动mysql'
# 启动mysql
service mysql start
# 使进程休眠3秒
sleep 3
echo `service mysql status`

echo '2.开始导入数据'
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
echo 'mysql容器启动完毕,且数据导入成功'

# 一直运行，保证docker不会被关闭
#echo "" >/usr/src/cron.log
#tail -f /usr/src/cron.log