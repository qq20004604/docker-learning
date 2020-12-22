#!/bin/bash
# Name:clear_tomcat_log.sh
# This is a ShellScript For Auto DB Backup and Delete old Backup
#
# 参数说明：
# backupdir 保存路径的绝对地址
# 代码中 time=` date +%Y%m%d`也可以写为time=”$(date +”%Y%m%d”)” 找到当前日期时间格式
# 其中`符号是TAB键上面的符号，不是ENTER左边的’符号，还有date后要有一个空格。
#mysql_bin_dir：mysql的bin路径；
#dataname：数据库名；
#user：数据库用户名；
#password：用户密码；
#name：自定义备份文件前缀标识
# name：自定义备份文件前缀标识。
# -type f    表示查找普通类型的文件，f表示普通文件。
# -mtime +30   按照文件的更改时间来查找文件，+30表示文件更改时间距现在30天以前；如果是 -mmin +7 表示文件更改时间距现在7分钟以前。
# -exec rm -rf {} \;   表示执行一段shell命令，exec选项后面跟随着所要执行的命令或脚本，然后是一对儿{}，一个空格和一个\，最后是一个分号。
#数据库备份的位置
time=` date +%Y_%m_%d_%H:%M:%S`
filename="$time.zip"
echo "$filename"
zip -r "$filename.zip" mysqldata