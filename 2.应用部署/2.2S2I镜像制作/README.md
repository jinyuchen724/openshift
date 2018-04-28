| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## s2i环境准备

- 在Master上下载S2I的二进制执行文件。
```
[root@hz01-online-ops-openmasteretc-01 /opt]# wget https://github.com/openshift/source-to-image/releases/download/v1.1.7/source-to-image-v1.1.7-226afa1-linux-amd64.tar.gz
```

- 解压到/usr/bin目录下
```
[root@hz01-online-ops-openmasteretc-01 /opt]# tar zxvf source-to-image-v1.1.7-226afa1-linux-amd64.tar.gz -C /usr/bin
```

## 创建项目目录

- 通过s2i create命令创建一个名为tomcat-s2i的S2I Builder镜像。第二个参数tomcat9-jkd1.8-s2i为S2I Builder镜像名称。第三个参数tomcat9-jkd1.8-s2i定义了工作目录的名称。

```
[root@hz01-online-ops-openmasteretc-01 /opt]# s2i create tomcat9-jkd1.8-s2i tomcat9-jkd1.8-s2i

[root@hz01-online-ops-openmasteretc-01 /opt]# find tomcat9-jkd1.8-s2i/
tomcat9-jkd1.8-s2i/
tomcat9-jkd1.8-s2i/s2i
tomcat9-jkd1.8-s2i/s2i/bin
tomcat9-jkd1.8-s2i/s2i/bin/assemble
tomcat9-jkd1.8-s2i/s2i/bin/run
tomcat9-jkd1.8-s2i/s2i/bin/usage
tomcat9-jkd1.8-s2i/s2i/bin/save-artifacts
tomcat9-jkd1.8-s2i/Dockerfile
tomcat9-jkd1.8-s2i/README.md
tomcat9-jkd1.8-s2i/test
tomcat9-jkd1.8-s2i/test/test-app
tomcat9-jkd1.8-s2i/test/test-app/index.html
tomcat9-jkd1.8-s2i/test/run
tomcat9-jkd1.8-s2i/Makefile
```

- s2i目录下为S2I脚本。

| 脚本名称 | 功能作用 | 操作系统 | etcd版本 |
| ---    | -----  |  --- | -------  |
| assemble | 负责源代码的编译、构建以及构建产出物的部署 | 
| run | S2I流程生成的最终镜像将以这个脚本作为容器的启动命令 | 
| usage | 打印帮助信息，一般作为S2I Builder镜像的启动命令 | 
| save-artifacts | 为了实现增量构建，在构建过程中会执行此脚本保存中间构建产物。此脚本并不是必需的 | 
