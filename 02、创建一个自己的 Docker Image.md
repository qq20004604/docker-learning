## 02、创建一个自己的 Docker Image

### 1、预期目标

* 实现一个 Express 的 Docker Image；
* 使用 Node.js 的 Express 框架，
* 使用最基本的 Demo 即可；

### 2、步骤

#### 2.1、先创建一个标准的 Express 项目

安装 Express（如果已经安装则略过）

```
npm install -g express
npm install -g express-generator
```

创建 Express 项目（找个目录，在该目录下运行这行命令）

```
express -t pug demo
cd demo
npm install
```

启动 Express

```
npm start
```

查看是否正常运行：打开浏览器，输入 ``localhost:3000``

如果正常显示内容，则说明OK

#### 2.2、忽略不需要打包的文件

项目根目录下，创建文本文件 ``.dockerignore``，这个文件类似 ``.gitignore``，里面写的文件将不会被打包到　image 目录里。

```
.git
node_modules
npm-debug.log
```

这三行写的有的是文件夹（比如是``node_modules``），有的是文件（比如 ``.npm-debug.log``），可以看见写法是一样的。

其他你不需要被打包的文件，也可以写在里面

---

#### 2.3、简单介绍 Dockerfile 文件

这个文件，就是用于描述项目该如何运行的。

先回想我们正常跑一个 Express 项目是什么样子的：

1. 先安装好 Node.js（不然node、npm命令都无法运行）；
2. 将一个可以跑的 express 项目拉到本地；
3. 通过 ``npm i`` 安装依赖；
4. 通过 ``npm start``　运行项目；

Docker是容器，所以显然是不存在任何运行环境的，因此需要复现以上行为，才能保证代码正常运行。

先创建 Dockerfile 文件，文件名是 ``Dockerfile``（注意，没有后缀名）：

<b>一些说明：</b>

* Dockerfile 文件里，每一行是一个命令；
* 命令可以分为两部分：【指令】和【指令参数】组成，例如``FROM node:8.4``，``FROM``就是指令，而``node:8.4``就是指令参数；
* 命令是从上到下按顺序执行的，直到执行完毕；
* 如果某行命令执行失败，那么将得到一个可以使用的 Image，方便调试；
* 可以注释，以 ``#`` 开头的行为注释行；
* 第一条命令必须使用指令 ``From``，该指令将指定一个已存在的 Image，后续指令将基于该 Image进行，该 Image 被称为 base image；
* 基础镜像可以是一个系统（比如 ubuntu），或者是某个配置好的环境（比如 node）；
* Docker 的很多 Image 都可以在 Docker 的 <a href="https://hub.docker.com/">官方库网站</a> 找到和查看；
* 剩下的将在具体代码中依次说明；

<br/>

#### 2.4、开始编辑 Dockerfile 文件

每个小标题将是一行命令，依次写入 Dockerfile 文件之中。

##### 2.4.1、创建 base image

命令：

```
FROM node:10.15.3
```

说明：

* 创建 base image，使用 Node.js 提供的 Node.js 版本为10.15.3 的 image；
* 查看 Docker 官方网站的 <a href="https://hub.docker.com/_/node">链接</a>；
* 也可以写为 ``FROM node:10``；

##### 2.4.2、将源代码拷贝进 image 中

命令：

```
COPY . /app
```

说明：

* 分为三部分：【指令 ``COPY`` 】，【当前目录 ``.`` 】，【Docker 的 image 里的目录 ``/app``】；
* 解释：将当前目录下的所有文件（``.``）拷贝（``COPY``）到 Docker 的 image 里的目录 （``/app``），``/app`` 之前的 ``/`` 表示根目录；
* 拷贝不包括 ``.dockerignore`` 文件里列出的文件夹和文件；
* 这个时候，项目目录就放到 image 里了；

##### 2.4.3、设置工作文件夹

命令：

```
WORKDIR /app
```

说明：

* 说明了一件事情，接下来的指令，如果跟目录相关，将执行于 image 里，根目录下的　``app`` 文件夹；
* 类似 ``cd /app`` 这样的指令；

##### 2.4.4、安装 npm 依赖包

命令：

```
RUN npm install --registry=https://registry.npm.taobao.org
```

说明：

* 注意，当前目录已经是 ``/app`` 了；
* npm install 大家都懂，装package.json 里面描述依赖的；
* ``RUN`` 表示执行一个命令，可以理解为在 shell 里我可以直接执行 ``npm i``，但是在 Dockerfile 里，他并不知道你要执行这样一个命令，所以你得告诉他；
* 后面加的 ``--registry=`` 参数是指定源，这里是使用淘宝提供的源（没有墙可能会快一些），你也可以不加参数；

<br/>
和 ``RUN`` 命令类似的还有 ``CMD`` 和 ``ENTRYPOINT``，区别如下：

1. RUN 执行命令并创建新的镜像层，RUN 经常用于安装软件包，比如这里的 ``npm install``；
2. CMD 设置容器启动后默认执行的命令及其参数，但 CMD 能够被 docker run 后面跟的命令行参数替换。
3. ENTRYPOINT 配置容器启动时运行的命令。

##### 2.4.5、暴露端口

命令：

```
EXPOSE 3000
```

说明：

* 默认的 Express 项目，他运行的端口是 3000，为了用户可以访问，当然要暴露出来啦；

#### 2.4.6、完整文件

```
FROM node:10.15.3
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 3000
```

注意，这里没有 ``npm start``，因为我们要在后面手动运行他。


#### 2.5、创建 image文件

命令：

```
docker image build -t docker-demo-01-express:0.0.1 .
```

说明：

* ``docker image build``：创建 image 文件；
* ``-t docker-demo-01-express``：image 文件名字为 ``docker-demo-01-express``；
* ``:0.0.1``：版本为 ``0.0.1``；
* ``.``：注意，最后还有一个点，表示是当前目录；
* 下载和生成 base image 还是蛮消耗时间的（毕竟蛮大的）；

创建成功后，会显示：

```
Successfully built 8520af6596ef
Successfully tagged docker-demo-01-express:0.0.1
```

并且运行 ``docker image ls`` 也能显示出创建的 image 了（还能看到 node 的 image）；

#### 2.6、生成容器

上面生成 image 是镜像，镜像是一个文件，并不能运行，因此我们还需要运行他，那就是容器（container）。

命令：

```
docker container run -p 8000:3000 -it docker-demo-01-express:0.0.1 /bin/bash
```

说明：

* ``docker container run``：从 image 文件生成容器；
* ``-p 8000:3000``：``3000`` 指容器端口（这里指 Express 使用的是 3000 端口，是通过 EXPOSE 3000 暴露出来的），``8000`` 映射到本机端口，即访问本机的 8000 端口 是访问容器的 3000端口；
* ``-it``：指在当前的 shell 里执行容器的 shell 命令（类似通过命令行 ssh 登录到服务器后，本地的命令行上实际上运行的是服务器的 shell）；
* ``docker-demo-01-express:0.0.1``：指运行该 image 的 0.0.1 版本；
* ``/bin/bash``：指容器启动后，内部执行的第一个命令（即 bash），这样才能在容器内部运行命令；

<br/>
运行该命令后，容器启动，并且进入容器的 shell 中。

此时执行命令：

```
npm start
```

然后打开 docker 所在机子的 8000 端口，即可访问 Express 项目了。

#### 2.7、简化

手动打那么多命令（比如还要手动执行 ``npm start``）实在没必要，我们希望运行容器后自动就可以运行了。

另外，注意端口之所以上面不一致，是因为实际情况中，可能本机配 3000 端口，线上使用 80 端口；

重新编写 ``Dockerfile`` 文件，内容最后一行添加 ``CMD npm start``，全部内容如下：

```
FROM node:10.15.3
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 3000
CMD npm start
```

<b>CMD指令说明：</b>

* RUN命令在 image 文件的构建阶段执行，执行结果都会打包进入 image 文件；
* CMD命令则是在容器启动后执行；
* 一个 Dockerfile 可以包含多个RUN命令，但是只能有一个CMD命令；

然后重新打包，这次就快很多了

```
docker image build -t docker-demo-01-express:0.0.1 .
```

再运行命令：

```
docker container run -d -p 3000:3000 -it docker-demo-01-express:0.0.1 >./id.log
```

效果：

* 重复的略，参考之前的；
* 后台运行容器；
* 本机可以通过 3000 端口访问到该容器；
* 返回一个容器日志id，在当前目录的 ``id.log`` 文件夹内；
* 可以通过 ``docker logs dockerID`` 来查看容器日志（dockerID 就在上面那个文件里）；


### 3、项目代码

参照链接：https://github.com/qq20004604/docker-learning/tree/master/docker-demo-01-express