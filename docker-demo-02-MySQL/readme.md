# 说明

详细内容参考【07、Docker与MySQL】一文。

## 1、文件夹说明

本文件夹：``docker-demo-02-MySQL`` ，是在已安装 Docker 的情况下，在本机创建 mysql 容器时 使用的。

使用时，直接在 终端/shell 里运行 ``sh create-image-mysql.sh`` 即可。

## 2、文件说明

【权限和默认密码】

修改 mysql 权限配置，修改 ``app/privileges.sql`` 文件；

【预创建的库和表，以及数据插入】

在 mysql 可运行后，创建库表，请修改 ``app/data.sql`` 文件；

【容器名】修改：

在 create-image-mysql.sh 里修改 containername 的值，默认是 mysql-demo

## 3、使用说明

正常情况下，运行完脚本，mysql 容器就应该已经启动了。可以输入 ``docker container ps -a`` 来查询。

如果没有启动，请手动运行 ``docker start [容器名]`` 来启动。


## 4、连接测试

输入以下代码：

```
mysql -h 127.0.0.1 -P 3306 -u root -p
```

然后输入密码即可，注意，这里不能用 localhost 密码，必须用基于指定ip（ip段）或基于所有ip访问的密码。

用我的shell脚本的默认密码是：``fwefwefvvdsbwrgbr9jj24intwev0h0nbor32fwfmv1``



## 5、查看宿主机的IP

```
ifconfig
```

可以用于只允许宿主机访问 mysql 容器。