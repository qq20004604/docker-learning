## 04、run与start的区别

两个命令的区别：

```
docker container run
```

```
docker container start [containerID]
```

### 1、run 命令

命令：

```
docker container run
```

说明：

* 创建好image后，新建容器时使用；
* 每次运行，都会创建一个新的容器；
* 新建的容器可以通过 ``docker container ls -a`` 或者 ``docker ps -a`` 查看（加 ``-a`` 表示查看所有创建好的容器）；
* 每次创建会返回一个【长的容器ID】；
* 通常情况下，运行一次即可；

示例：

```
[root@qq20004604 docker-demo-01-express]# docker ps -a
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS                      PORTS                    NAMES
f46b174f0c69        docker-demo-01-express:0.0.1   "/bin/sh -c 'npm sta…"   19 hours ago        Up 19 hours                 0.0.0.0:3000->3000/tcp   musing_sinoussi
197f0e8f5874        docker-demo-01-express:0.0.1   "/bin/sh -c 'npm sta…"   19 hours ago        Exited (137) 19 hours ago                            quirky_allen
bf399d6b0563        docker-demo-01-express:0.0.1   "-d"                     19 hours ago        Created                     0.0.0.0:3000->3000/tcp   elastic_brown
616c433342fb        docker-demo-01-express:0.0.1   "/bin/sh -c 'npm sta…"   19 hours ago        Exited (137) 19 hours ago                            friendly_pascal
3922627183cd        docker-demo-01-express:0.0.1   "/bin/sh -c 'npm sta…"   19 hours ago        Exited (130) 19 hours ago                            loving_tharp
4ddca7626abf        docker-demo-01-express:0.0.1   "/bin/sh -c 'npm sta…"   19 hours ago        Exited (130) 19 hours ago                            lucid_mirzakhani
9ac35930e780        8520af6596ef                   "/bin/bash"              19 hours ago        Exited (130) 19 hours ago                            zealous_allen
cdeb3db4961d        8520af6596ef                   "/bin/bash"              19 hours ago        Exited (130) 19 hours ago                            laughing_gates
47743e952f66        hello-world                    "/hello"                 29 hours ago        Exited (0) 29 hours ago                              agitated_antonelli
```

### 2、start 命令

命令：

```
docker container start [containerID]
```

说明：

* 只有新建好的容器（能通过命令查到的），才可以使用本命令；
* 使用命令的前提是该容器【已经生成】并且【已经停止运行】；
* 容器ID通过 ``docker container ls -a`` 或者 ``docker ps -a`` 查看；

### 3、区别

* 当我们新建好一个 image 文件时，需要通过 ``docker container run`` 来生成一个容器；
* 当该容器不需要停止运行的时候，我们停止掉它；
* 当我们需要重新运行这个容器的时候，使用 ``docker container start [containerID]`` 再次打开它；

### 4、其他容器管理命令

参照下一节【05、容器的管理】
