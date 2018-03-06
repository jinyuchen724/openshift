 | 版本 | 日期 | 状态 | 修订人 | 摘要 |
 | -- | --- | --- | ---- | ---- |
 | V1.0 |2017-01-18 | 新建 | 伏华 | 初次编写文档 |
 
# Openshift v3.6 架构图
OpenShift 是一款容器应用平台，它将 Docker 和 Kubernetes 技术带入企业。无论您采用何种应用架构，OpenShift 都能让您在任意架构中（公共或私有云中）轻松、快速实现应用的构建、开发和部署。无论是在企业内部，公共云，或是托管环境中，您都能凭借这一备受业务青睐的平台，快速您的最新创意推向市场，从而在激烈的市场竞争中脱颖而出。

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/4fecaec4-c401-4b15-9d38-10a867dc945f.png)

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/13a27419-6168-4d61-b70f-127d8c24cea6.jpg)

**主服务器(Masters)依赖于基于etcd的分布式目录， 主要用来提供配置共享和服务发现**
**计算节点(Nodes) 主要用来作为PODS的宿主和运行容器**

# 部署主机角色说明 

| 主机角色 | IP地址 | 操作系统 | 摘要 |
| --- |
| 管理节点(Master)  | openshift-master(192.168.124.22) | CentOS Linux release 7.3.1611 (Core) x86_64  | 安装master |
| 计算节点(Node) | openshift-node1（192.168.124.30） | CentOS Linux release 7.3.1611 (Core) X86-64 | 计算节点 |
| 计算节点(Node) | openshift-node2（192.168.124.46） | CentOS Linux release 7.3.1611 (Core) X86-64 | 计算节点 |
 
 **注：以下所有配置操作均在 Centos 7.3(x86_64) 环境下完成，其他环境请酌情参考**

# 安装前基础环境检查
## 配置仓库源(如果自己建立本地源 直接跳过本步骤)
- 安装仓库源文件
```
yum install centos-release-openshift-origin.noarch
```
- 修改仓库配置 指向 V3.6版本(默认是最新的3.7版本)
```
[root@openshift-master ~]# cat /etc/yum.repos.d/CentOS-OpenShift-Origin.repo
[centos-openshift-origin]
name=CentOS OpenShift Origin
baseurl=http://mirrors.163.com/centos/7.4.1708/paas/x86_64/openshift-origin36/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-PaaS
其他省略。。。。。。。。
```
主要是把 
**http://mirror.centos.org/centos/7/paas/x86_64/openshift-origin/**
修改为下面链接(使用163镜像)
**http://mirrors.163.com/centos/7.4.1708/paas/x86_64/openshift-origin36/**

# 安装master节点软件包
```
yum install  origin-master -y
```
# 安装master节点需要的服务
```
yum install httpd-tools java ansible 
```
## 启动master
```
systemctl enable origin-master.service
systemctl start origin-master.service
```
## admin用户登陆配置文件说明

- admin 用户登陆使用密钥文件
```
/etc/origin/master/admin.kubeconfig
```
- 管理员登陆 使用证书密钥进行管理(当前用户是root)

```
mkdir -p /root/.kube
cp /etc/origin/master/admin.kubeconfig    /root/.kube/config
oc login -u system:admin
[root@openshift-master ~]# oc login -u system:admin
Logged into "https://192.168.124.22:8443" as "system:admin" using existing credentials.

You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default
    kube-public
    kube-system
    openshift
    openshift-infra

Using project "default".
[root@openshift-master ~]# oc whoami
system:admin
```

- 执行 如下命令可以看到当前登录用户
```
[root@centos7-tradesystem .kube]# oc whoami
system:admin
```
# 安装node节点(计算节点)
- 设置仓库源（参考上面）
- 安装 node 软件包
```
yum install origin-node -y
```
- 生成 node 配置文件(默认是没有的) 
 - 将master的 ca配置文件 拷贝到 node 节点 (master节点上操作)
 
 ```
 cd /etc/origin/master/
 scp ca.crt ca.key ca.serial.txt openshift-node1:/etc/origin/node/
 ```
 - 在node节点上 生成配置(node节点上操作)

```
# cat addnode.sh 
#!/bin/bash

NODE_NAME=`hostname`
NODE_IP=`ifconfig eth0 |grep '172' |awk '{print $2}'`
MASTER_IP=172.16.5.244

   oc adm create-node-config \
    --node-dir=/etc/origin/node \
    --node=$NODE_NAME \
    --hostnames=$NODE_NAME,$NODE_IP \
    --certificate-authority="/etc/origin/node/ca.crt"   \
    --signer-cert="/etc/origin/node/ca.crt"   \
    --signer-key="/etc/origin/node/ca.key"   \
    --signer-serial="/etc/origin/node/ca.serial.txt" \
    --node-client-certificate-authority="/etc/origin/node/ca.crt" \
    --master='https://'$MASTER_IP':8443'
 ```
-  启动node节点

```
systemctl enable origin-node
systemctl start origin-node
```
- 检查日志和到服务端确认node注册成功

```
[root@openshift-master master]# oc get node
NAME              STATUS    AGE       VERSION
openshift-node1   Ready     27s       v1.6.1+5115d708d7
```
# 设置Node节点 docker(所有计算节点都需要设置)
- 配置docker

```
[root@openshift-node1 node]# cat /etc/docker/daemon.json
{
 "registry-mirrors": ["http://ef017c13.m.daocloud.io"],
 "insecure-registries": [ "172.30.0.0/16","172.30.102.47:5000","hz01-prod-ops-openshiftmaster-01.sysadmin.xinguangnet.com:5000"]
}

```
- 重启docker

```
systemctl daemon-reload
systemctl restart docker
```

经过如上配置，一个基础openshift 环境就算安装完成，下面我们来建立一个基础的容器云
# openshift v3.6 企业级初级应用部署
## 整体应用概念介绍

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/cb27a00c-601a-4e57-94a2-0bface8d8dd3.jpg)

上述应用架构图中， 概念来源于Kubernetes的概念， 需要明白以下主要的对象。

- 一个 **POD** 是一个Docker 容器的运行环境（如果需要共享本地的资源， 我们将在单独的POD中布署两种类别的容器）
- 一个 **Service** 服务是一个入口(VIP)，抽象出一个均衡访问负载到一组相同的容器，理论上， 最少是一个服务对应一个架构层
- 一个服务布署者(**Service Deployer**)或布署配置(**Deployment Config**)是一个对象， 用来描述基于触发器的容器的布署策略（比如，当docker注册表中有新版本的映象时， 重新布署）。
- 一个复制控制器(**Replication Controller**)是一个技术组件， 主要负责POD 的弹性。
- 一个路由(**Route**)是用来显露一个应用的入口（域名解析， 主机名或VIP）

## 主机功能规划
| 主机角色 | IP地址 | 操作系统 | 摘要 |
| --- |
| 管理节点(Master)  | openshift-master(192.168.124.22) | CentOS Linux release 7.3.1611 (Core) x86_64  | 安装master |
| 计算节点(Node) | openshift-node1（192.168.124.30） | CentOS Linux release 7.3.1611 (Core) X86-64 | 计算节点 运行router服务，内部镜像仓库服务 |
| 计算节点(Node) | openshift-node2（192.168.124.46） | CentOS Linux release 7.3.1611 (Core) X86-64 | 计算节点 |

## 部署 Router 组件 （用户访问的入口，域名都需要指向Router组件运行的node节点上）
通过对Node节点打标签，在部署组件的时候，可以指定部署到特定节点上
- 给Node节点打标签

```
[root@openshift-master master]# oc label node openshift-node1 ops=yes
node "openshift-node1" labeled
[root@openshift-master master]# oc get node --show-labels
NAME              STATUS    AGE       VERSION             LABELS
openshift-node1   Ready     3h        v1.6.1+5115d708d7   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=openshift-node1,ops=yes
openshift-node2   Ready     31m       v1.6.1+5115d708d7   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=openshift-node2
```
- 建立一个 service account 关联router 并赋予权限

```
[root@openshift-master ~]# oc project default
[root@openshift-master ~]# oadm policy add-scc-to-user privileged system:serviceaccount:default:router
[root@openshift-master ~]# oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:router
cluster role "cluster-reader" added: "system:serviceaccount:default:router"
```
- 创建一个名为 router01 的实例，在指定的计算节点上

```
[root@openshift-master ~]# oadm router router01 --replicas=1 --service-account=router --selector='ops=yes'
info: password for stats user admin has been set to iC3sKtFY5k
--> Creating router router01 ...
    serviceaccount "router" created
    clusterrolebinding "router-router01-role" created
    deploymentconfig "router01" created
    service "router01" created
--> Success

查看状态
[root@openshift-master ~]# oc get pod -n default
NAME                READY     STATUS              RESTARTS   AGE
router01-1-deploy   0/1       ContainerCreating   0          1m
正在下载docker images  过几分钟再看(取决于下载速度)
[root@openshift-master ~]# oc get pod -n default
NAME               READY     STATUS    RESTARTS   AGE
router01-1-hvc1j   1/1       Running   0          1m
```

## 部署registry(内部使用的docker仓库),主要存放源代码打包生成的镜像 同样部署在node1节点上
```
[root@openshift-master ~]# oadm registry --config=/etc/origin/master/admin.kubeconfig  --service-account=registry --selector='ops=yes'
--> Creating registry registry ...
    serviceaccount "registry" created
    clusterrolebinding "registry-registry-role" created
    deploymentconfig "docker-registry" created
    service "docker-registry" created
--> Success
[root@openshift-master ~]# oc get pod
NAME                       READY     STATUS              RESTARTS   AGE
docker-registry-1-deploy   0/1       ContainerCreating   0          3s
router01-1-hvc1j           1/1       Running             0          14h
[root@openshift-master ~]# oc get pod
NAME                      READY     STATUS    RESTARTS   AGE
docker-registry-1-k5zq1   1/1       Running   0          3m
router01-1-hvc1j          1/1       Running   0          14h
```
## 查看各个SERVICE的内部集群地址
```
[root@openshift-master ~]# oc get svc
NAME              CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
docker-registry   172.30.111.126   <none>        5000/TCP                  9m
kubernetes        172.30.0.1       <none>        443/TCP,53/UDP,53/TCP     22h
router01          172.30.121.139   <none>        80/TCP,443/TCP,1936/TCP   15h
```
注意: 172.30.0.0/16 这个段是 cluster ip,如果容器出现问题或者迁移，这个 cluster ip 是不会改变的 
## 将 registry 通过 route 暴露到集群外，方便其他系统对接测试
- 给registry创建route 访问的域名是  **registry.ops.com**

``` 
[root@openshift-master ~]# oc expose service docker-registry --hostname=registry.ops.com -n default
route "docker-registry" exposed
```
- 查看route

```
[root@openshift-master ~]# oc  get route
NAME              HOST/PORT          PATH      SERVICES          PORT       TERMINATION   WILDCARD
docker-registry   registry.ops.com             docker-registry   5000-tcp                 None
```

- 测试registry 访问 （域名解析到 route 所在的节点上 或者 hosts绑定)

```
[root@openshift-master ~]# curl -I http://registry.ops.com/healthz
HTTP/1.1 200 OK
Cache-Control: no-cache
Date: Fri, 19 Jan 2018 05:50:58 GMT
Content-Type: text/plain; charset=utf-8
Set-Cookie: 172555eec50a0d95563a405b15a8a45f=a8887127305ff63dc9305e4cbde4230b; path=/; HttpOnly
```

## 导入模板和镜像(导入了部分模板)
```
导入基础镜像
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/image-streams/image-streams-centos7.json -n openshift
imagestream "httpd" created
imagestream "ruby" created
imagestream "nodejs" created
imagestream "perl" created
imagestream "php" created
imagestream "python" created
imagestream "wildfly" created
imagestream "mysql" created
imagestream "mariadb" created
imagestream "postgresql" created
imagestream "mongodb" created
imagestream "redis" created
imagestream "jenkins" created

导入应用模板
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mariadb-ephemeral-template.json -n openshift
template "mariadb-ephemeral" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mariadb-persistent-template.json -n openshift
template "mariadb-persistent" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mongodb-ephemeral-template.json -n openshift
template "mongodb-ephemeral" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mongodb-persistent-template.json -n openshift
template "mongodb-persistent" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mysql-ephemeral-template.json -n openshift
template "mysql-ephemeral" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mysql-persistent-template.json -n openshift
template "mysql-persistent" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/redis-ephemeral-template.json -n openshift
template "redis-ephemeral" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/redis-persistent-template.json -n openshift
template "redis-persistent" created
[root@openshift-master ~]#
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/cakephp-mysql.json -n openshift
template "cakephp-mysql-example" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/cakephp-mysql-persistent.json -n openshift
template "cakephp-mysql-persistent" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/jenkins-ephemeral-template.json -n openshift
template "jenkins-ephemeral" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/jenkins-persistent-template.json -n openshift
template "jenkins-persistent" created
[root@openshift-master ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/httpd.json -n openshift
template "httpd-example" created
```
## 查看导入的镜像列表
```
[root@openshift-master ~]# oc project openshift
Now using project "openshift" on server "https://192.168.124.22:8443".
[root@openshift-master ~]#  oc get is -n openshift
NAME         DOCKER REPO                                TAGS                           UPDATED
httpd        172.30.111.126:5000/openshift/httpd        latest,2.4                     About an hour ago
jenkins      172.30.111.126:5000/openshift/jenkins      latest,1,2                     About an hour ago
mariadb      172.30.111.126:5000/openshift/mariadb      10.1,latest                    About an hour ago
mongodb      172.30.111.126:5000/openshift/mongodb      2.4,latest,3.2 + 1 more...     About an hour ago
mysql        172.30.111.126:5000/openshift/mysql        latest,5.7,5.6 + 1 more...     About an hour ago
nodejs       172.30.111.126:5000/openshift/nodejs       latest,0.10,4 + 1 more...      About an hour ago
perl         172.30.111.126:5000/openshift/perl         latest,5.24,5.20 + 1 more...   About an hour ago
php          172.30.111.126:5000/openshift/php          5.5,latest,7.0 + 1 more...     About an hour ago
postgresql   172.30.111.126:5000/openshift/postgresql   latest,9.5,9.4 + 1 more...     About an hour ago
python       172.30.111.126:5000/openshift/python       latest,3.5,3.4 + 2 more...     About an hour ago
redis        172.30.111.126:5000/openshift/redis        latest,3.2                     About an hour ago
ruby         172.30.111.126:5000/openshift/ruby         2.3,2.2,2.0 + 1 more...        About an hour ago
wildfly      172.30.111.126:5000/openshift/wildfly      latest,10.1,10.0 + 2 more...   About an hour ago
```

## 查看导入的应用模板列表(相当于企业内部的APPSTORE 应用市场)
```
[root@openshift-master ~]# oc get templates -n openshift
NAME                       DESCRIPTION                                                                        PARAMETERS        OBJECTS
cakephp-mysql-example      An example CakePHP application with a MySQL database. For more information ab...   19 (4 blank)      8
cakephp-mysql-persistent   An example CakePHP application with a MySQL database. For more information ab...   20 (4 blank)      9
httpd-example              An example Httpd application that serves static content. For more information...   9 (3 blank)       5
jenkins-ephemeral          Jenkins service, without persistent storage....                                    7 (all set)       6
jenkins-persistent         Jenkins service, with persistent storage....                                       8 (all set)       7
mariadb-ephemeral          MariaDB database service, without persistent storage. For more information ab...   7 (3 generated)   3
mariadb-persistent         MariaDB database service, with persistent storage. For more information about...   8 (3 generated)   4
mongodb-ephemeral          MongoDB database service, without persistent storage. For more information ab...   8 (3 generated)   3
mongodb-persistent         MongoDB database service, with persistent storage. For more information about...   9 (3 generated)   4
mysql-ephemeral            MySQL database service, without persistent storage. For more information abou...   8 (3 generated)   3
mysql-persistent           MySQL database service, with persistent storage. For more information about u...   9 (3 generated)   4
redis-ephemeral            Redis in-memory data structure store, without persistent storage. For more in...   5 (1 generated)   3
redis-persistent           Redis in-memory data structure store, with persistent storage. For more infor...   6 (1 generated)   4
```
## 配置openshift sdn 网络(否则 docker build 会出现 如下错误)

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/39b3805a-6faa-4647-82da-16d8d3a4283d.jpg)
- 所有计算节点都需要安装 **origin-sdn-ovs** 软件包 (如果master节点也做计算节点的话，也需要安装)
```
yum install origin-sdn-ovs.x86_64 -y
```
- 修改 主节点(master) 和 计算节点(node)的配置文件（红色框框原来默认是空的）
**/etc/origin/master/master-config.yaml**
![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/33307ced-4c3f-40c4-be17-1abc7aac018e.jpg)
重启master 节点
```
systemctl daemon-reload
systemctl restart origin-master
```
- 修改所有计算节点的配置,与master设置一致
**/etc/origin/node/node-config.yaml**
![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/f14afea6-7992-4b79-8276-085de180fcf7.jpg)
重启计算节点(node)
```
systemctl daemon-reload
systemctl restart origin-node
```
**注意： master 节点网络配置 和  计算节点(node) 一定要一致**

- 通过在master 节点执行如下命令查看分配到各个节点的子网
```
[root@openshift-master ~]# oc get hostsubnets
NAME              HOST              HOST IP          SUBNET
openshift-node1   openshift-node1   192.168.124.30   10.128.0.0/23
openshift-node2   openshift-node2   192.168.124.46   10.129.0.0/23
```

#配置node节点dns
```
[root@hz01-prod-ops-openshiftnode-01 /]# vim /etc/origin/node/node-config.yaml
dnsIP: "172.30.0.1"     #将此配置选项改成172.30.0.1，即svc/kubernetes的CLUSTER-IP
dnsNameservers: null
dnsRecursiveResolvConf: ""

[root@hz01-prod-ops-openshiftnode-01 /]# systemctl restart origin-node
#trouble shooting：
在安装metric监控服务时由于没有配置dns导致docker内部服务无法通讯。

```

#部署度量采集服务

- clone ansible工程及切换分支

```
[root@hz01-prod-ops-openshiftmaster-01 /opt] git clone https://github.com/openshift/openshift-ansible.git
[root@hz01-prod-ops-openshiftmaster-01 /opt/openshift-ansible] git checkout origin/release-3.6
```

# 度量采集架构图

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/83b99786-111e-41b4-9ed0-b1fcc99def08.png)

- 使用ansible进行部署

```
1.配置/etc/ansible/hosts部署文件
[root@hz01-prod-ops-openshiftmaster-01 /]# vim /etc/ansible/hosts 
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=root
openshift_deployment_type=origin
openshift_metrics_install_metrics=True
openshift_metrics_image_prefix=openshift/origin-
#拉取的镜像版本
openshift_metrics_image_version=v3.6.0-alpha.2
openshift_metrics_resolution=10s
#metrics_hawkular服务对外的域名
openshift_metrics_hawkular_hostname=metrics.open-prod.ops.com
#master的ip
openshift_metrics_master_url=https://172.16.5.244:8443

[masters]
hz01-prod-ops-openshiftmaster-01

[nodes]
hz01-prod-ops-openshiftnode-01
hz01-prod-ops-openshiftnode-02

2.执行ansible-playbook(第一次执行可能会失败，如果失败就再执行一次)

[root@hz01-prod-ops-openshiftmaster-01 /]# ansible-playbook /opt/openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml -e openshift_metrics_install_metrics=True

3.卸载命令
[root@hz01-prod-ops-openshiftmaster-01 /]# ansible-playbook /opt/openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml -e openshift_metrics_install_metrics=False

4.执行结果，部署的快慢根据由拉取镜像的速度决定，成功的结果如下(READY都是1/1表示成功)
# oc get pod -n openshift-infra
NAME                         READY     STATUS    RESTARTS   AGE
hawkular-cassandra-1-m1p40   1/1       Running   0          4m
hawkular-metrics-lf9hb       1/1       Running   0          4m
heapster-1c2h0               1/1       Running   0          4m

5.检查master-config.yaml配置
[root@hz01-prod-ops-openshiftmaster-01 /]# vim /etc/origin/master/master-config.yaml
masterPublicURL: https://172.16.5.244:8443
metricsPublicURL: https://metrics.open-prod.ops.com/hawkular/metrics/  #检查此选项配置
publicURL: https://172.16.5.244:8443/console/

```

# 成功后查看监控信息

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/871088ae-c469-466c-b104-cbe338ce6ce7.jpg)

# 部署日志采集服务

# 日志服务架构图



```
#因为每个节点都需要采集日志，所以新建的logging项目选择的标签为空。
[root@hz01-prod-ops-openshiftmaster-01 /]# oc adm new-project  logging --node-selector=""  

#修改ansible配置文件
[root@hz01-prod-ops-openshiftmaster-01 /]# vim /etc/ansible/hosts
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=root
openshift_deployment_type=origin
openshift_logging_kibana_hostname=kibana.open-prod.ops.com
openshift_logging_master_url=https://172.16.5.244:8443

[masters]
hz01-prod-ops-openshiftmaster-01

[nodes]
hz01-prod-ops-openshiftnode-01
hz01-prod-ops-openshiftnode-02

#执行安装日志采集服务
[root@hz01-prod-ops-openshiftmaster-01 /]#ansible-playbook /opt/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml 


[root@hz01-prod-ops-openshiftmaster-01 /root]
# oc get pod
NAME                                      READY     STATUS    RESTARTS   AGE
logging-curator-1-01khs                   1/1       Running   0          1d
logging-es-data-master-f9r7g76t-1-bpvkq   1/1       Running   0          1d
logging-fluentd-05cr8                     1/1       Running   0          1d
logging-fluentd-wc8ht                     1/1       Running   0          1d
logging-kibana-1-h4rl1                    2/2       Running   0          1d
```

# 权限管理
- 安装完默认是任意密码登陆，这里配置htpasswd方式进行认证

![权限管理配置](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/d963948b-cbde-474c-bb1e-0d8b400f901c.jpg "权限管理配置")

- 安装htpasswd

```
[root@hz01-dev-ops-openshiftmaster-01 /] # yum install httpd-tools

```
- 添加ops账户

```
[root@hz01-dev-ops-openshiftmaster-01 /]# touch /etc/origin/master/htpasswd

[root@hz01-dev-ops-openshiftmaster-01 /] # htpasswd -b /etc/origin/master/htpasswd ops ops

将ops用户加入openshift-infra项目，并赋予admin权限
[root@hz01-dev-ops-openshiftmaster-01 /] # oc adm policy add-role-to-user admin ops -n openshift-infra
```

# 应用数据持久化

- 我们共享存储采用的是ceph，所以这里使用ceph与openshift集成

- 添加所有node节点配置（如果需要使用ceph）

```
#安装ceph客户端
[root@hz01-prod-ops-openshiftnode-01 /root]# yum install ceph-common

#添加加粗字体的配置文件，否则会导致无法挂载rbd。
[root@hz01-prod-ops-openshiftnode-01 /root]# vim /etc/origin/node/node-config.yaml
volumeConfig:
  **dynamicProvisioningEnabled: true**
  localQuota:
    perFSGroup: null

[root@hz01-prod-ops-openshiftnode-01 /root]# systemctl restart origin-node
```

```
# 1.在ceph节点上执行获取client.admin的key
[root@hz-01-ops-tc-ceph-02 /]# ceph auth get-key client.admin | base64
QVFEdGcxaGFOd0gySWhBQVdYaGNBcU9YZlkxYkZjNTEvVWdzVUE9PQ==
```
```
# 2.创建ceph-secret文件。
[root@hz01-prod-ops-openshiftmaster-01 /opt] vim ceph-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  #name表示生成secret自定义的名字。
  name: ceph-secret   
  namespace: default
data:
  #key是由第一步获取的client.admin的key以base64加密的秘钥
  key: QVFEdGcxaGFOd0gySWhBQVdYaGNBcU9YZlkxYkZjNTEvVWdzVUE9PQ==  
type:
  kubernetes.io/rbd
```

```
# 3.生成密码
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc create -f ceph-secret.yaml 
secret "ceph-secret" created
```

```
# 4.查看生成的ceph密码
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc get secret ceph-secret 
NAME          TYPE                DATA      AGE
ceph-secret   kubernetes.io/rbd   1         15d
```

```
# 5.在ceph集群上的操作
# 5.1创建kube的池子
[root@hz-01-ops-tc-ceph-02 /root]# rados mkpool kube
successfully created pool kube

# 5.2查看ceph的池子
[root@hz-01-ops-tc-ceph-02 /root]# rados lspools
rbd
ceph01
ceph02
walong
kube

# 5.3在kube这个pool中创建image
[root@hz-01-ops-tc-ceph-02 /root]# rbd create kube/ceph-image3 --size 10240 --image-format 2

# 5.4查看kube下的image
[root@hz-01-ops-tc-ceph-02 /root]# rbd ls kube
ceph-image3

# 5.5创建并生成持久化的卷
[root@hz01-prod-ops-openshiftmaster-01 /opt]# vim ceph-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  #持久化卷自定义的名字 
  name: ceph-pv3
spec:
  capacity:
    #分配给这个卷的大小
    storage: 10Gi
	#这个卷的权限模式
  accessModes:
    - ReadWriteOnce
  #使用ceph中块设备的模式，openshift会调用ceph rbd的插件
  rbd:
    #ceph服务端的地址和端口
    monitors:
      - 172.16.2.231:6789,172.16.2.172:6789,172.16.2.181:6789
	# 使用的ceph集群的池子名称
    pool: kube
	# 使用的ceph集群的image名称
    image: ceph-image3
    user: admin
    secretRef:
      name: ceph-secret
	# Ceph RBD块设备上的文件系统类型
    fsType: xfs
	# 这里需要读写，所以只读为false
    readOnly: false
  persistentVolumeReclaimPolicy: Recycle
```

```
# 6.查看持久化卷的信息
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc get pv
NAME       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS   CLAIM      STORAGECLASS   REASON    AGE
ceph-pv3   10Gi       RWO           Retain          Bound     default/ceph-claim3                            1h
```

```
# 7. 创建并生成持久化卷的声明
[root@hz01-prod-ops-openshiftmaster-01 /opt]# vim ceph-claim.yaml 
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ceph-claim3
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
	  #该声明将寻找2Gi以上的pv
      storage: 2Gi
```

```
# 8.查看pvc
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc get pvc
NAME          STATUS    VOLUME     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
ceph-claim3   Bound     ceph-pv3   10Gi       RWO                          1h
```

```
# 9.创建测试应用
[root@hz01-prod-ops-openshiftmaster-01 /opt]# vim ceph-pod1.yaml
apiVersion: v1
kind: Pod
metadata:
  #pod的名字，自定义
  name: ceph-pod1
spec:
  containers:
  - name: ceph-busybox
    #启动的镜像名
    image: busybox
    command: ["sleep", "60000"]
    volumeMounts:
	#挂载卷的名字
    - name: ceph-vol2
	  #挂载的路径
      mountPath: /usr/share/busybox
      readOnly: false
  securityContext:
    fsGroup: 7777
  volumes:
    #挂载卷的名字，需要与容器中挂载卷的名字一致。
  - name: ceph-vol2
    persistentVolumeClaim:
	  #使用的pvc的名字
      claimName: ceph-claim3
```

```
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc create -f ceph-pod1.yaml 
pod "ceph-pod1" created
```

```
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc get pod
NAME               READY     STATUS    RESTARTS   AGE
ceph-pod1          1/1       Running   0          29s
router01-1-gxfvj   1/1       Running   0          16d
```

```
# 10.测试存储持久化是否生效
10.1 在持久化挂载目录下创建一些文件及目录
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc rsh po/ceph-pod1
/ # cd /usr/share/busybox/
/usr/share/busybox # mkdir 123
/usr/share/busybox # touch 123/234
/usr/share/busybox # exit
command terminated with exit code 130

10.2 删除pod
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc delete pod ceph-pod1
pod "ceph-pod1" deleted

10.3 重新启动pod，查看挂载目录下数据是否丢失
[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc create -f ceph-pod1.yaml 
pod "ceph-pod1" created

[root@hz01-prod-ops-openshiftmaster-01 /opt]# oc rsh  po/ceph-pod1
/ # ls /usr/share/busybox/123/234
#数据都在说明挂载成功
```

# 通过web ui的方式创建一个应用
- 使用 **test/test** 登陆

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/ebf0f164-6336-4369-bc28-1cc3f69e8e83.jpg)






# OpenShift中的持续交付（生产环境中的2种部署方式）
## OpenShift在产品环境的部署默认是rolling的方式

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/aaae6383-91f7-49d0-8d96-50dd08c77173.jpg)

每次部署时，它会启动一个新的Replica Controller，部署一个pod，然后削减旧的Replica Controller的pod，
如此往复，直到旧的Replica Controller中的所有pod都被销毁，新的Replica Controller的所有pod都在线。
整个过程保证了服务不宕机以及流量平滑切换，对用户是无感知的。

## 蓝绿部署的方式

![](/web_upload/markdown/picture/7b7d463e-167d-43e3-91bd-9efbb4c0ae60/b252511e-8a91-44af-a8ee-e9d80627f4ab.jpg)

而有的时候部署场景要负责些，比如我们想在产品环境对新版本做了充分的PVT（product version testing）预发环境,才切换到新版本。
蓝绿部署方案的关键点在于一个Router对应两个Service。而Route作为向外界暴露的服务端口是不变的，两个Service分别对应我们的生产蓝环境和生产绿环境。同时只有一个Service能接入Router对外服务，另一个Service用来进行PVT测试。切换可以简单的修改Router的配置即可
