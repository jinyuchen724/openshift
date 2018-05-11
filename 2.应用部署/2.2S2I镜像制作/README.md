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

- 通过s2i create命令创建一个名为tomcat-s2i的S2I Builder镜像。第二个参数tomcat9-jdk1.8-s2i为S2I Builder镜像名称。第三个参数tomcat9-jdk1.8-s2i定义了工作目录的名称。

```
[root@hz01-online-ops-openmasteretc-01 /opt]# s2i create tomcat9-jdk1.8-s2i tomcat9-jdk1.8-s2i

[root@hz01-online-ops-openmasteretc-01 /opt]# find tomcat9-jdk1.8-s2i/
tomcat9-jdk1.8-s2i/
tomcat9-jdk1.8-s2i/s2i
tomcat9-jdk1.8-s2i/s2i/bin
tomcat9-jdk1.8-s2i/s2i/bin/assemble
tomcat9-jdk1.8-s2i/s2i/bin/run
tomcat9-jdk1.8-s2i/s2i/bin/usage
tomcat9-jdk1.8-s2i/s2i/bin/save-artifacts
tomcat9-jdk1.8-s2i/Dockerfile
tomcat9-jdk1.8-s2i/README.md
tomcat9-jdk1.8-s2i/test
tomcat9-jdk1.8-s2i/test/test-app
tomcat9-jdk1.8-s2i/test/test-app/index.html
tomcat9-jdk1.8-s2i/test/run
tomcat9-jdk1.8-s2i/Makefile
```

- s2i目录下为S2I脚本。

| 脚本名称 | 功能作用 | 
| ---    | -----  | 
| assemble | 负责源代码的编译、构建以及构建产出物的部署 | 
| run | S2I流程生成的最终镜像将以这个脚本作为容器的启动命令 | 
| usage | 打印帮助信息，一般作为S2I Builder镜像的启动命令 | 
| save-artifacts | 为了实现增量构建，在构建过程中会执行此脚本保存中间构建产物。此脚本并不是必需的 | 

# 开始项目工作
## 编写Dockerfile

编写一个制作Tomcat的S2I镜像。Dockerfile的内容如下：
```
# tomcat9-jdk1.8-s2i
FROM openshift/base-centos7

ENV appname NONE
ENV env NONE
ENV url NONE
#ENV war NONE
ENV http NONE

LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
    io.k8s.description="Tomcat9 S2I builder" \
    io.k8s.display-name="tomcat s2i builder 1.0" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,tomcat9"

RUN mkdir -p /etc/yum.repos.d/
RUN mkdir -p /usr/local/
ADD local-mirror.repo /etc/yum.repos.d/

RUN yum -y install curl vim net-tools wget java unzip maven
ENV BUILDER_VERSION 1.0
COPY apache-tomcat-9.0.2.tar.gz /tmp

RUN tar -xvf /tmp/apache-tomcat-9.0.2.tar.gz -C /opt/
RUN mkdir -p /opt/app-root
RUN mv /opt/apache-tomcat-9.0.2 /opt/app-root/tomcat
RUN chmod -R 777 /opt/app-root
RUN chown -R 1001:0 /opt/app-root
RUN rm -rf /opt/app-root/tomcat/webapps/*

RUN mkdir -p /usr/local/tomcat/logs
RUN chmod -R 777 /usr/local/tomcat/
RUN chown -R 1001:0 /usr/local/tomcat/

COPY ./s2i/bin/ /usr/libexec/s2i

USER 1001
EXPOSE 8080
#ENTRYPOINT []
#CMD ["usage"]
#ADD run.sh /opt/
CMD ["/usr/libexec/s2i/usage"]

```
注意: 通过**USER 1001**定义系统用户，并指定该用户为容器的启动用户。以root用户作为启动用户在某些情况下存在安全风险

```
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# make
```

- 安装配置docker-registry

```
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# yum install docker-registry -y
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# vim /etc/docker/daemon.json
{
 "registry-mirrors": ["http://ef017c13.m.daocloud.io"],
 "insecure-registries": [ "172.30.0.0/16","172.30.102.47:5000","hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000"]
}
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# systemctl restart docker
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# systemctl restart docker-distribution
```

- 仓库配置完毕，打好标签后，推送至镜像仓库
```
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# docker tag tomcat9-jdk1.8-s2i hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000/tomcat9-jdk1.8-s2i
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# docker push hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000/tomcat9-jdk1.8-s2i
```

- 通过import-image将镜像导入openshift项目中
```
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# oc import-image hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000/tomcat9-jdk1.8-s2i -n openshift --confirm --insecure
The import completed successfully.

Name:			tomcat9-jdk1.8-s2i
Namespace:		openshift
Created:		Less than a second ago
Labels:			<none>
Annotations:		openshift.io/image.dockerRepositoryCheck=2018-04-29T12:26:26Z
Docker Pull Spec:	172.30.128.130:5000/openshift/tomcat9-jdk1.8-s2i
Image Lookup:		local=false
Unique Images:		1
Tags:			1

latest
  tagged from hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000/tomcat9-jdk1.8-s2i
    will use insecure HTTPS or HTTP connections

  * hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000/tomcat9-jdk1.8-s2i@sha256:d1404fd3a6bfb638b9ecfd7a6cde2c59d3ef63a4fdf10a04678372cf7a373ee4
      Less than a second ago

Image Name:	tomcat9-jdk1.8-s2i:latest
Docker Image:	hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com:5000/tomcat9-jdk1.8-s2i@sha256:d1404fd3a6bfb638b9ecfd7a6cde2c59d3ef63a4fdf10a04678372cf7a373ee4
Name:		sha256:d1404fd3a6bfb638b9ecfd7a6cde2c59d3ef63a4fdf10a04678372cf7a373ee4
Created:	Less than a second ago
Image Size:	506.3 MB (first layer 1.39 kB, last binary layer 73.17 MB)
Image Created:	3 hours ago
Author:		<none>
Arch:		amd64
Command:	usage
Working Dir:	<none>
User:		1001
Exposes Ports:	8080/tcp
Docker Labels:	io.k8s.description=Tomcat9 S2I builder
		io.k8s.display-name=tomcat s2i builder 1.0
		io.openshift.expose-services=8080:http
		io.openshift.s2i.scripts-url=image:///usr/libexec/s2i
		io.openshift.tags=builder,tomcat9
		org.label-schema.schema-version== 1.0     org.label-schema.name=CentOS Base Image     org.label-schema.vendor=CentOS     org.label-schema.license=GPLv2     org.label-schema.build-date=20180402
Environment:	PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		appname=NONE
		env=NONE
		url=NONE
		http=NONE
```

- 查看导入的镜像
```
[root@hz01-online-ops-openmasteretc-01 /opt/openshift/tomcat9-jdk1.8-s2i]# oc get is -n openshift |grep tomcat
tomcat9-jdk1.8-s2i   172.30.128.130:5000/openshift/tomcat9-jdk1.8-s2i   latest     27 seconds ago
```
