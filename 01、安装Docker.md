## 01、安装Docker

参考文章：

* <a href="http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html">Docker 入门教程（阮一峰）</a>

### 1、Centos安装Docker

<b>Docker版本：</b>

* 安装版本是CE（社区版）；
* 除了社区版之外，还有EE（企业版）（付费）；

<b>系统要求：</b>

* 要求Centos7，不能是测试版；
* 其他系统可以从参考文章里，找对应的系统的安装说明；

<b>安装方式：</b>

* 通过 repository 来安装（常规模式）（这里采取）；
* 通过 rpm 模式来安装（断网的话就只能这样咯）；
* 通过 sh脚本 来安装（不推荐在生产环境使用，不安全）（<a href="https://get.docker.com/">脚本1</a>，<a href="https://test.docker.com/">脚本2</a>）；

<b>名词解释：</b>

* <b>image：</b>可以理解为容器，或者是运行环境，应用程序和依赖，将被打包进 image 文件里；


<b>步骤：</b>

1、卸载旧版本Docker：

```
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine
```

一路yes和确定即可；

---

2、开始安装（这里使用的是第一种安装模式）：

依赖包：

```
sudo yum install -y yum-utils \
	device-mapper-persistent-data \
  	lvm2
```

添加源：

```
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

安装Docker CE版：

```
sudo yum install docker-ce docker-ce-cli containerd.io
```

---

3、安装完毕，查看 Docker 版本

如果安装成功，以下命令可以查看docker版本

```
docker version
```

显示内容参考如下：

```
[root@qq20004604 src]# docker version
Client:
 Version:           18.09.5
 API version:       1.39
 Go version:        go1.10.8
 Git commit:        e8ff056
 Built:             Thu Apr 11 04:43:34 2019
 OS/Arch:           linux/amd64
 Experimental:      false
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

最后一行表示当前 Docker 服务未启动。

---

4、启动Docker

```
sudo service docker start
# 或下面这行
sudo systemctl start docker
```

启动成功后显示：

```
[root@qq20004604 src]# sudo service docker start
Redirecting to /bin/systemctl start docker.service
```

列出本机所有的image文件（如果已经启动的话）：

```
[root@qq20004604 src]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```

显示的内容是title，没有第二行，表示本地还没有 image


### 2、跑一个最简单的Docker项目

1、拉取一个线上的 docker 项目：

```
docker image pull hello-world
```

2、然后查看本地 image 列表：

```
[root@qq20004604 src]# docker image ls
```

显示：

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              fce289e99eb9        3 months ago        1.84kB
```

3、运行

```
docker container run hello-world
```

输出以下内容，并停止运行这个容器（因为他并不需要一直运行下去）：

```
[root@qq20004604 src]# docker container run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

4、恭喜，Docker 安装并运行成功。