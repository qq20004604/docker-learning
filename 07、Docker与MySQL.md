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


#### 2.4、将 MySQL 数据放在容器之外

等等，虽然 MySQL 跑起来了，但是数据还在容器里呀？

解决方法很简单，将容器内外 link 起来即可。

核心方法是创建容器时，通过参数：``-v [容器外路径]:[容器内路径]`` 来实现。

这样当容器内路径（该文件夹）下内容有所改动时，会被同步到容器之外。

####　2.5、测试收尾，移除旧的 MySQL 容器：

* 先执行 ``docker containers ps -a`` 查到所有容器，然后找到测试用的容器的 ID；
* 再执行 ``docker rm [containerID]`` 删除测试容器；

####　3、数据持久化

命令：

```
docker run --name mysql-demo -v $PWD/mysqldata:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234567890 mysql:5.6
```

说明：

* 基于 MySQL 5.6 持久化生成容器；
* 关键命令是：``-v $PWD/mysqldata:/var/lib/mysql``；
* 此时 MySQL 的数据，既保存在容器内，也保存在容器外；
* 容器外本机目录为：``$PWD/mysqldata``，即当前目录下（``$PWD``）的 mysqldata 文件夹下；
* 容器内目录是 ``/var/lib/mysql``（这个是 MySQL 默认目录）；
* 其他之前都写了，略；


---
## 【以下未完成，正在修订中】


### 3、制作一个属于自己的 MySQL image

按照正常思路，使用 Docker 时，应当尽量避免在创建容器后，进入容器进行配置，这会带来很多麻烦。

所以我们应该自己制作一个 MySQL 的 image，然后生成容器时，所有该配置的都配置完了。

为了实现这样的目标，我们要做的，当然是写一个自己的 image了。

#### 3.1、基本思路

需要的东西：

* <b>Dockerfile文件：</b>既然是制作自己的 image，那么自定义 Dockerfile 文件自然少不了；
* <b>权限管理SQL：</b>数据库当然离不了权限管理，为了预先配置好权限管理，那么相关 SQL 文件也是必须的；
* <b>预创建SQL：</b>数据库通常需要一些 database 和 table，所以需要有一个这样的 SQL 文件；
* <b>脚本文件：</b>上面2个SQL需要手动执行，所以当然也需要一个 shell 文件来实现啦；

先预先写好 2 个 SQL，然后写好执行 SQL 文件的 shell 脚本，

#### 3.2、文件目录

```
create-image-mysql.sh    # 运行这个脚本创建镜像
app                       # 用于创建 image 的文件夹
|--Dockerfile             # Docker 创建 image 的配置文件
|--data.sql               # 预创建数据库表SQL，用于在数据库初始化后，创建一些需要的database和table
|--privileges.sql         # 权限管理SQL，相关权限管理的SQL写在这里
|--init.sh                # shell脚本，在这里将上面的SQL文件执行
```



#### 3.3、Dockerfile

文件内容：

```
# 指定基础镜像，使用MySQL:5.6版本（因为5.7版本比较复杂）
FROM mysql:5.6
# 环境变量设置，设置mysql登陆时不需密码
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes
COPY . /app
WORKDIR /app
# 容器启动命令启动脚本
CMD ["sh", "./init.sh"]
```

说明：

* Dockerfile 文件做了这几件事情：【继承mysql5.6】、【初始化mysql登录不需要密码】、【将app文件夹的内容拷贝到容器内app文件夹】、【容器启动时，执行脚本】；
* 注意：``CMD`` 命令只会在创建容器时执行，所以说只会执行一次；
* Dockerfile 描述了容器初始创建时，会是什么样的状态；




#### 3.4、init.sh（脚本文件）

文件内容：

```
#!/usr/bin/env bash
set -e
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
```

说明：

* 这个文件做了这些事情：【启动 MySQL（因为继承基础镜像，所以不会默认启动）】、【修改数据权限】、【导入基本数据】；
* 这个文件将在容器启动后执行；
* 执行完这个文件，此时 MySQL 已经进入可用状态了（并且有了基本的权限管理和基本的数据库表）；





#### 3.5、privileges.sql（权限管理SQL）

文件内容：

```
use mysql;
select host, user from user;
-- 将docker_mysql数据库的权限授权给创建的docker用户，密码为 1234567890，但只能本机访问（指容器内）
-- 如果用户docker不存在，则创建用户docker
grant all on docker_database.* to docker@'localhost' identified by '1234567890' with grant option;
-- 其他任意地方可以访问，需要使用密码 1654879wddgfg
grant all on docker_database.* to docker@'%' identified by '0987654321' with grant option;
-- mysql新设置用户或权限后需要刷新系统权限否则可能会出现拒绝访问：
flush privileges;
```

说明：

* 可以查看注释；
* 简单来说，允许【容器内】用户，通过使用账号 docker，密码 1234567890 来登录；
* 允许【来自任何IP】的用户，通过使用账号 docer，密码 0987654321 来登录；
* 这个时候权限管理就做好了；





#### 3.6、data.sql（预创建数据库表SQL）

文件内容：

```
-- 创建数据库
DROP database IF EXISTS `docker_test_database`;
create database `docker_test_database` default character set utf8 collate utf8_general_ci;
-- 切换到 docker_test_database 数据库
use docker_test_database;
-- 建表
DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
	`id` bigint(20) NOT NULL,
	`name` varchar(255) DEFAULT NULL,
	`age` bigint(20) NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
-- 插入数据
INSERT INTO `user` (`id`,`name`,`age` )
VALUES
   (0,'Tom',18);
```

说明：

* 创建一个基础的数据库，这里是用于测试使用；
* 创建 database，然后创建 table，再然后插入数据；
* 没了~；
* 如果有需求，可以自己写符合需求的 SQL 来实现；


#### 3.7、create-image-mysql.sh（创建镜像脚本）

文件内容：

```
#!/usr/bin/env bash
docker image build -t docker-demo-02-mysql:0.0.1 ./app
if [ ! -d "mysql-data" ]; then
  mkdir mysql-data
fi
docker container run --name mysql-demo -v mysql-data:/var/lib/mysql -p 3306:3306 -dit docker-demo-02-mysql:0.0.1
```

