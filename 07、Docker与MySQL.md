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

###　3、数据持久化

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

### 4、持久化 + SQL预执行

理论上来说，我们期望 Docker 镜像生成容器并启动完毕后，我们就不需要进行管理了。

但实际上来说，很多时候并不能满足这样的要求。

以 MySQL 为例，一些权限管理、库表预创建之类的事情，并不能在创建的时候就实现。

并且在我实际实践中，MySQL 5.6 在作为 我们自定义的 Docker 的基础镜像时，虽然可以正常运行。但如果生成容器时添加了持久化配置，却会提示权限错误无法正常运行。

因为这样的原因，我决定将原本一次性操作（生成镜像后自动执行脚本），拆分为两步：

1. 基于 MySQL 5.6 的镜像，使用持久化配置；
2. 生成容器后，手动执行脚本来实现预先配置；

#### 3.1 预先准备内容

避免手动执行命令，因此我们应该预先准备一些脚本。

先列出文件目录：

```
create-image-mysql.sh    # 运行这个脚本创建容器
app                       # 用于在容器内执行的内容放这里
|--init.sh                # shell脚本，在这里将上面的SQL文件执行
|--data.sql               # 预创建数据库表SQL，用于在数据库初始化后，创建一些需要的database和table
|--privileges.sql         # 权限管理SQL，相关权限管理的SQL写在这里
```

其中：

* ``create-image-mysql.sh``：这个脚本将于用于创建容器、创建数据持久化文件夹、将数据拷贝进容器并执行脚本；
* ``app``：这个文件夹内容将被拷贝进脚本，具体功能将在下面解释；

#### 3.2、create-image-mysql.sh 创建管理容器

初始情况下，我们只有一个下载好的 MySQL5.6 镜像（甚至都木有这个镜像，但这个耗时就太久了）。所以这个脚本要做的事情很多，包括下载image，创建容器，将容器外脚本拷贝进容器，执行初始化脚本等。

文件内容：

```
#!/usr/bin/env bash
# 如果需要使用其他镜像，记得自行修改脚本
# 修改映射到本机的端口也一样

appfilename="app"
mysqldatafilename="mysqldata"
imagename="docker-demo-02-mysql:0.0.1"
containername="mysql-demo"

# 建立持久化文件夹
if [ ! -d $mysqldatafilename ]; then
  mkdir "$mysqldatafilename"
fi

echo "【1】下载 mysql:5.6.43 版本 image"
docker pull mysql:5.6.43
echo "下载完成或无需下载"

echo "【2】先用原本镜像生成容器，初始化不需要密码（后续添加），并进行持久化配置"
echo "$PWD/$mysqldatafilename"
docker run --name "$containername" -d -v "$PWD/$mysqldatafilename":/var/lib/mysql -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:5.6.43

# 如果自己手动执行的话，下面这行脚本可以在创建容器时即添加账号密码
#docker run --name mysql-demo -d -v "$PWD/$mysqldatafilename":/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234567890 mysql:5.6.43

# 然后把 app 文件拷贝到容器里面
echo "【3】然后把 app 文件拷贝到容器里面"
docker cp "$PWD/$appfilename" "$containername":/

echo "【4】执行容器内的初始化脚本"
docker exec "$containername" sh "/$appfilename/init.sh"
```

说明：

* 这个脚本做了这些事情：
* 【下载mysql镜像】：为了防止没有相关镜像，所以直接下载。如果已经下载的话并没有什么影响；
* 【通过镜像生成容器】：这个生成过程，包括持久化设置、设置端口映射、初始化不需要密码等；
* 【将app文件夹拷贝到容器内】：其中 init.sh 文件是必须的，其他根据 init.sh 文件的内容而定；
* 【执行在容器内的 init.sh 文件】：用于初始化容器的配置；
* 注意一件事情，当执行这里最后一行脚本时，并不代表容器内 MySQL 服务已经完全启动完毕。所以在 init.sh 脚本内做了等待处理，以增加容错性；


#### 3.3、核心脚本：init.sh

所有在容器内，需要执行的内容，比如 SQL 脚本呀，或者是一些配置内容呀，都通过它来执行。

在这个脚本里，有以下命令：

```
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
```

说明：

* 在这个脚本里，做了这些事情：
* 【等待 MySQL 启动完毕】：由于第一次启动容器后，mysql 服务并不是立即可用的（他需要一定时间来配置），因此我们手动等待15秒时间（具体等待多久，跟服务器性能有关）；
* 【导入预创建库表SQL】：可能我们需要预先创建一些库和表格，将这些sql语句写入 ``data.sql`` 文件中；
* 【权限管理SQL】：之所以这个SQL放到后面，是因为初始情况我们不需要密码就能导入数据（启动容器时配置的环境变量），导入这个SQL后，之后再导入sql文件就需要账号密码了；
* 【通报完毕，并显示提示信息】：告知用户什么情况下是正确的状况（虽然理论上也可以自己写个脚本判断输出）；
* 【其他】：如果你有其他需要执行的命令，可以在这个脚本里执行，或者写在其他shell文件里，在这个脚本里执行该shell文件；

---

#### 3.4、创建库表SQL

正常情况下， MySQL 往往需要预创建一些 database 和 table，以供程序使用，而这些最好在容器创建的时候就做到。

这里是由 ``data.sql`` 文件来实现的。

在这个 SQL 文件里，有以下内容：

```
-- 创建数据库
DROP database IF EXISTS `docker_test_database`;
create database `docker_test_database` default character set utf8 collate utf8_general_ci;
-- 切换到test_data数据库
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
INSERT INTO `person` (`id`,`name`,`age` )
VALUES
   (0,'Tom',18);
```

说明：

* 这个SQL文件做了以下事情：
* 【如果有库docker_test_database，则扔掉】：只有当需要一个新的database才需要这么写；
* 【创建docker_test_database】：创建 database，并切换到这个 database；
* 【如果有表person，则扔掉】：原因同上面；
* 【建立表】：创建table，并预设表结构；
* 【插入一条测试数据】：如果插入成功，说明 MySQL 可以正常运行；
* 如果需要其他sql操作，也可以写在这个 SQL 文件里，或者每个database一个sql文件，然后依次导入。

#### 3.5、权限管理SQL

一个良好的数据库必然会有多个不同权限的角色，只有这样才能确保数据库的安全性和稳定性。因此，我们需要有一个权限管理SQL。

文件内容：

```
use mysql;
select host, user from user;
-- 任意地点的root账号可以用一个非常复杂的密码登录（瞎打的），用于禁止无密码登录
GRANT ALL ON *.* to root@'%' identified by 'fwefwefvvdsbwrgbr9jj24intwev0h0nbor32fwfmv1' with grant option;
-- 允许root用户以密码 123456 来登录（仅限本地）
GRANT ALL ON *.* to root@'localhost' identified by '123456' with grant option;
-- 将 docker_test_database 数据库的权限授权给创建的docker用户，密码为 1234567890，但只能本机访问（指容器内）
-- 如果用户docker不存在，则创建用户docker
GRANT ALL ON docker_test_database.* to docker@'localhost' IDENTIFIED by '1234567890';
-- 其他任意地方可以访问，需要使用密码 1654879wddgfg
GRANT ALL ON docker_test_database.* to docker@'%' IDENTIFIED by '1654879wddgfg';
-- mysql新设置用户或权限后需要刷新系统权限否则可能会出现拒绝访问：
FLUSH PRIVILEGES;
```

说明：

* 这个脚本里做了这些事情：
* 【切换到mysql这个库】：这个库负责权限管理；
* 【查看当前用户有哪些】：显示当前mysql用户；
* 【禁止创建容器时设置的无密码登录】：这个是为了安全性所实现的，密码尽量复杂一些，因为这个是允许远程访问root账号；
* 【允许root用户本地登录】：这个是本机（容器内）登录root账号，所以密码可以简单一些。但若有实际需要，也应该写复杂一些。
* 【为docker_test_database这个库创造一个用户】：这个用户 docker 专门负责操作 docker_test_database 这个 database，所以权限比较低一些，允许本地访问（有密码）；
* 【允许docker用户远程访问】：这个是为了测试远程可以访问数据库，也可以不允许远程访问（避免出现数据库入侵）；
* 总的来说，是权限控制的一些内容。这个SQL推荐在最后执行，避免其他SQL输入数据时需要密码的问题。

#### 3.6、验证

远程验证链接为：

```
mysql -h [远程主机IP地址] -P 3306 -u root -p
```

然后输入密码即可。


### 4、总结

将以上文件拷贝到主机，然后执行 create-image-mysql.sh 脚本即可。会自动安装并配置好 MySQL。

通过以上操作，我们实现了需求。现在，我们再来回顾一下这个需求做了什么事情：

* 安装了 MySQL 5.6 版本；
* 持久化 MySQL 数据（将 MySQL 数据存储到容器外）；
* 预先创建了一些 database 和 table；
* 对 MySQL 进行了权限管理配置；

本项目资源请在我的github项目地址查看：

https://github.com/qq20004604/docker-learning