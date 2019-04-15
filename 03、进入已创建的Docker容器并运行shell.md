## 03、进入已创建的Docker容器并执行bash命令

### 1、情况描述

我们会遇见这样一种情况，一个Docker容器执行一段时间后，出错了，这个时候我们需要查看到底是因为什么原因出错。

正常情况，我们进入 shell ，然后通过各种命令调试，但是 Docker 的容器一般是后台运行的，所以显然没办法这样做。

那么解决方法很简单，进入 Docker 容器，通过容器的 shell 来调试。

### 2、进入容器的命令

命令：

```
docker exec -it 容器ID /bin/bash

```

说明：

* 【容器ID】可以通过命令：``docker ps`` 或者 ``docker container ls``获得；
* 以上命令默认是获取运行的，如果要获取所有的，可以在最后加参数 ``-a``；
* 上面查看到的是【短ID】；
* 创建容器时，会返回一个【长ID】；
* 两个 ID 都可以使用；

<br/>
示例：（部分内容被省略）

```
[root@qq20004604 docker-demo-01-express]# docker container ls
CONTAINER ID        IMAGE
f46b174f0c69        docker-demo-01-express:0.0.1

[root@qq20004604 docker-demo-01-express]# docker exec -it f46b174f0c69 /bin/bash
root@f46b174f0c69:/app# 
```

### 3、接下来

你就可以为所欲为了~~。

### 4、退出容器的shell

方法很简单：

* ctrl + D
* 输入 ``exit`` 命令