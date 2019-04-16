## 07、Docker与MySQL

### 1、场景说明和使用思路

<b>场景说明：</b>

既然说服务器，怎么能离开各种数据库呢？而 MySQL 显然是最好用的数据库之一。

但是博主自己经验来说，最讨厌配 MySQL 的环境了，还好有 Docker 可以简单解决这个问题。

<b>使用思路：</b>

Docker的容器是可以被删除、复制的。

但显然，MySQL 作为一个数据库，是不能接受这样的情况发生（因为会导致数据丢失）。

初步的解决思路，是容器负责业务逻辑，而存储数据存储于容器外。

这样，便实现了业务代码（指 MySQL 的逻辑部分）与数据（指数据文件）分离的效果。

<b>其他说明：</b>

为了方便省事，使用 MySQL5.6 版本。

因为 5.7 版本，会有一些很麻烦的事情出现。


### 2、生成MySQL容器

#### 2.1、拉取MySQL镜像

命令：

```
docker pull mysql:5.6
```

效果：

拉取了 MySQL 5.6 版本最新的 image

```
[root@qq20004604 ~]# docker images
REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
docker-demo-01-express   0.0.1               416f1050c9bf        42 hours ago        907MB
mysql                    5.6                 98455b9624a9        2 weeks ago         372MB
```

#### 2.2、生成一个MySQL容器

命令：

```
docker container run --name [name] -p 3306:3306 -e MYSQL_ROOT_PASSWORD=[password] -d mysql:[version]
```

示例代码：

```
docker container run --name mysql-demo -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234567890 -d mysql:5.6
```

说明：


* ``docker container run``：通过image启动容器，也可以写为 ``docker run``，但推荐使用更全的命令；
* ``--name [name]``：生成的容器的名字，如果不写，则会随机生成一个名字；
* ``-p 3306:3306``：将容器端口映射本机端口；
* ``-e MYSQL_ROOT_PASSWORD=[password]``：设置环境变量，这里指设置 MySQL 的默认密码。注意，不需要带括号也不需要带引号来包裹密码；
* ``-d mysql:[version]``：这里指你基于哪个 MySQL 来生成容器；

示例代码如上，效果是：

* 生成一个MySQL容器，容器名字是 ``mysql-demo``；
* 容器是基于 MySQL 5.6 的 image 生成的；
* 可以通过访问主机的端口 3306 来访问容器里的 MySQL；
* MySQL 的初始密码是1234567890；


#### 2.3、进行一些配置

首先，我们通常需要远程访问，所以要配置一下。

<b>进入容器的 MySQL：</b>

* ``docker container ps -a`` 列出所有容器；
* 然后 ``docker container exec -it [containerID] /bin/bash`` 进入容器并输入命令行；
* 此时已经进入容器了；
* ``mysql -u root -p`` 进入mysql，会提示输入密码，输入密码即可（如果按我上面示例代码，默认密码是 ``1234567890``；

---

<b>对 MySQL 进行配置：</b>

允许 MySQL 被远程访问：

```
grant all privileges on *.* to 'root'@'%' identified by '[password]';
flush privileges;
```

* ``[password]``：是密码，他被引号所包含在内，允许任何一个 IP 访问 root 账号通过上面这个密码；
* 第二行是刷新上面这行配置；
* 注意，本机访问密码和这里的访问密码是独立的（互不干扰）；

---

<b>此时情况：</b>

可以在其他机子上远程访问 MySQL，远程访问命令：

```
mysql -h [serverIP] -P 3306 -u root -p 
```

然后输入密码即可登录进去了

---

<b>其他：</b>

1. 如果有类似 ``the 'information_schema.session_variables' feature is disabled`` 这样的报错，尝试使用 ``set @@global.show_compatibility_56=ON;`` 来解决。通常是因为使用 5.7 版本而不是 5.6 版本而出现的；


####　2.4、将 MySQL 数据放在容器之外

to be continue