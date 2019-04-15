## 06、container、image、文件的互相转化

### 1、情况说明

* image（又称为镜像）：是通过 ``Dockerfile``　file创建的，通过 ``docker image ls`` 查看；
* container（容器）：是 image 通过 ``docker container run [image]`` 来生成；
* 文件（就是文件）：方便管理，适用于将一个服务器上的image转移/拷贝其他服务器上（虽然也可以通过传到 Docker 官方仓库来实现）；

他们各有适用范围，但在某些情况下，需要互相转化。

### 2、image转container和文件

#### 2.1 转container

之前提过，略；

#### 2.2 转文件

命令：

```
docker save [image名] > [文件路径(需要是tar文件)]
```

说明：

* ``[image名]``：通过 ``docker image ls`` 来查询；
* ``[文件路径(需要是tar文件)]``：将 image 打包为一个 tar 文件；
* 然后就可以拷贝走这个 tar 文件了，至于如何转回 image，参考下面；

### 3、container转image和文件

#### 3.1、转image

命令：

```
docker commit [containerID] [imagename]:[version]
```

说明：

* ``docker commit``：表示container转image，固定的，很好理解；
* ``[containerID]``：一个容器的ID，可以是运行状态；
* ``[imagename]``：转换后的 image 的名字，可以自定义，很好理解；
* ``:[version]``：<b>可选</b>，tag，也可以认为是版本号，不加默认是 ``latest``，加了就是指定的tag；

示例：

```
docker commit f46b174f0c69 c2image:0.0.2
```

结果：

```
[root@qq20004604 ~]# docker image ls
REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
c2image                  0.0.2               2b86002ebd4b        4 seconds ago       907MB
docker-demo-01-express   0.0.1               416f1050c9bf        21 hours ago        907MB
```

#### 3.2、转文件

命令：

```
docker export [containerID] > [文件路径(需要是tar文件)]
```

说明：

* ``docker export [containerID] >``：都好理解，略略略；
* ``[文件路径(需要是tar文件)]``：将容器打包为一个 tar 文件；
* 容器打包成文件，比 image 打包成文件要小一些，因为它丢失了历史和数据元metadata；

### 4、文件转image和container

#### 4.1、转image

<b>基本说明：</b>

* 【tar文件】可以是从 image 转来的，也可以是从 container 转来的；
* 这些【tar文件】都可以转为 image；
* 转换并不会带来之前的日志（指转换前的），所以如果需要日志，记得提前备份；

<b>方法一：</b>

命令：

```
docker load < [tar文件路径]
```

说明：

* 将 tar文件 转为 image；
* 转换完后，可以通过 ``docker images`` 查看；
* 这种方法似乎并不能指定转换结束后的 image 的名字；

---

<b>方法二：</b>

命令：

```
docker import [tar文件名] [imagename]:[version]
```

说明：

* ``docker import``：导入，固定的意思，略；
* ``[tar文件名]``：就是来自于容器或者image压缩成的【tar文件】咯；
* ``[imagename]``：导入后的 imagename，如果不写，那么最后名字和tag都将是 ``<none>``；
* ``:[version]``：<b>可选</b>，tag名，如果不填，则默认为 ``latest``；

#### 4.2、转容器

没必要，先转 image，再从 image 生成容器；

