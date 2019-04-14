## 02、创建一个自己的 Docker Image

### 1、预期目标

* 实现一个 Express 的 Docker Image；
* 使用 Node.js 的 Express 框架，
* 使用最基本的 Demo 即可；

### 2、步骤

<b>1、先创建一个标准的 Express 项目</b>

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

---

<b>2、忽略不需要打包的文件</b>

项目根目录下，创建文本文件 ``.dockerignore``，这个文件类似 ``.gitignore``，里面写的文件将不会被打包到　image 目录里。

```
.git
node_modules
npm-debug.log
```

这三行写的有的是文件夹（比如是``node_modules``），有的是文件（比如 ``.npm-debug.log``），可以看见写法是一样的。

其他你不需要被打包的文件，也可以写在里面

---

<b>3、配置 Dockerfile 文件</b>

这个文件，就是用于描述项目该如何运行的。

先回想我们正常跑一个 Express 项目是什么样子的：

1. 先安装好 Node.js（不然node、npm命令都无法运行）；
2. 将一个可以跑的 express 项目拉到本地；
3. 通过 ``npm i`` 安装依赖；
4. 通过 ``npm start``　运行项目；

