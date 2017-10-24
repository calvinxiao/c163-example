# c163-example
一步一步教大家在网易蜂巢上部署Node.js应用
- [第一章，Hello world](#第一章，Hello world)

## 第一章，Hello world

### 第一步，创建`app.js`文件

```javascript
const http = require('http')

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' })
  res.end('Hello world.')
})

server.listen(3000, '0.0.0.0', () => {
  console.log('listening on port 3000', )
})
```

简单测试一下

```
% node app.js
listening on port 3000
% curl http://localhost:3000
Hello world.%

```

### 第二步，创建 docker 镜像

> 先确保本机安装了docker

创建Dockerfile

```
FROM hub.c.163.com/library/node:8.4.0-alpine
MAINTAINER xiaojiawei@yeezon.com
COPY . /app
WORKDIR /app
EXPOSE 3000
CMD node --max-old-space-size=600 app.js
```

Node.js的alpine镜像体积小，可以加快镜像的构建速度，网易蜂巢提供了镜像中心，国内pull的速度非常快，不过最近好像镜像的同步速度慢了，
写本文的时候 Node.js 的版本是`8.7`。

接着build一个镜像，名字为 `c163-example:hello-world`

```
docker build . -t c163-example:hello-world
Sending build context to Docker daemon  102.4kB
Step 1/6 : FROM hub.c.163.com/library/node:8.4.0-alpine
8.4.0-alpine: Pulling from library/node
280aca6ddce2: Already exists
32194206c3e6: Already exists
8611baeb41d5: Already exists
Digest: sha256:4959dec6321ba4bdad3927026e0f32e4a9342ba76e8a96fe7b84800dbdf015ee
Status: Downloaded newer image for hub.c.163.com/library/node:8.4.0-alpine
 ---> 016382f39a51
Step 2/6 : MAINTAINER xiaojiawei@yeezon.com
 ---> Using cache
 ---> ee1fff2be90d
Step 3/6 : COPY . /app
 ---> 9f78061786d0
Step 4/6 : WORKDIR /app
 ---> 31ee4391cc71
Removing intermediate container 595275c2d9f9
Step 5/6 : EXPOSE 3000
 ---> Running in 9fbd9a253d9a
 ---> 92592b21a39f
Removing intermediate container 9fbd9a253d9a
Step 6/6 : CMD node --max-old-space-size=600 app.js
 ---> Running in 08ab36706b86
 ---> b22bb08141ed
Removing intermediate container 08ab36706b86
Successfully built b22bb08141ed
Successfully tagged c163-example:hello-world
```

可以 run 一下刚 build 好的镜像，确保没有出错

```
% docker run --rm -p 3000:3000 c163-example:hello-world
listening on port 3000
```

## 第三步，部署到蜂巢

首先你要有一个帐号，去[网易蜂巢](http://c.163.com/channel?redirect=https%3A%2F%2Fc.163.com%2F&cid=dc170331203826004050) 注册便可。
阿里云和腾讯云都有对应的容器服务，用法相差不大。

拿到帐号和密码后，在本机的终端登录蜂巢的镜像中心

```
docker login -u 帐号 -p 密码 hub.c.163.com
```

看到成功的信息后就可以把刚建好的镜像文件传到镜像中心

```
# 先打个tag，替换下面的cookiebody为你自己的蜂巢用户名
% docker tag c163-example:hello-world hub.c.163.com/cookiebody/c163-example:hello-world
% docker push hub.c.163.com/cookiebody/c163-example:hello-world
The push refers to a repository [hub.c.163.com/cookiebody/c163-example]
bf4282031dab: Pushed
0b3e54ee2e85: Pushed
ad77849d4540: Pushed
5bef08742407: Pushed
hello-world: digest: sha256:1ef0b294304720397e99c363090e9ee70ede4b227d0cdd7a5c198f0b002abf7c size: 10514
```

这时候在后台的镜像中心应该可以看到刚 push 上去的镜像了。

![](//asset.ibanquan.com/image/59ef00a33f8f9006520000fe/s.jpeg?v=1508835492)

因为默认是私有镜像，我把它设成公有了，[链接](https://c.163.com/hub#/m/repository/?repoId=77731)。

接着来创建一个无状态服务，点击 【容器服务】-> 【创建服务】

![](//asset.ibanquan.com/image/59ef035e921f507ebd000086/s.png?v=1508836190)

无状态服务允许你设置环境变量和日志目录，而且一个服务里面可以有多个容器，不过目前我们并不需要多个容器

![](//asset.ibanquan.com/image/59ef04173f8f900652000109/s.png?v=1508836376)

选择规格，有钱的可以选择高配，目前最高可以选择32核64G，配置好端口和副本数量就可以创建服务副本了

![](//asset.ibanquan.com/image/59ef0628b1b9570b2500013c/s.png?v=1508836904)

一般一分钟内就创建好了

![](//asset.ibanquan.com/image/59ef06780dd76c0fec0000b1/s.png?v=1508836984)

这时候我们可以去创建一个负载均衡，把外网80端口的流量转发到新建的服务

![](//asset.ibanquan.com/image/59ef07d9921f507ebd000090/s.jpeg?v=1508837337)

点击 [http://59.111.108.201/](http://59.111.108.201/)便可测试

### 总结

云服务减轻了技术人员的运维负担，容器云以及Serverless等服务更是提高了技术产品发布和迭代的效率。




