| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 部署主机角色说明

| 主机角色 | IP地址 |  域名 |
| ---      | -----  |  ---  |
| 基础设施节点(Node) | openshift-node1（172.16.8.104） | *.open-prod.ops.com |
| 计算节点(Node) | openshift-node2（172.16.8.42） | 无对外域名 |
| 计算节点(Node) | openshift-node2（172.16.5.109） | 无对外域名 |

## 安装node节点(计算节点)

- 设置仓库源（参考主服务安装）

- 安装docker
```
[root@hz01-online-ops-opennode-01 /opt]# yum install docker -y
```

- 配置docker

```
[root@hz01-online-ops-opennode-01 /opt]# cat /etc/docker/daemon.json
{
 "registry-mirrors": ["http://ef017c13.m.daocloud.io"],
 "insecure-registries": [ "172.30.0.0/16","172.30.102.47:5000","openshift-master1:5000"]
}
```

注意: **insecure-registries** 代表docker 使用http 而不使用https(默认是https方式)访问 docker镜像仓库

- 启动docker

```
[root@hz01-online-ops-opennode-01 /opt]# systemctl enable docker
[root@hz01-online-ops-opennode-01 /opt]# systemctl start docker
```

- 安装 node 软件包
```
[root@hz01-online-ops-opennode-01 /opt]# yum install origin-node origin-sdn-ovs -y
```
## 生成 node 配置文件(默认是没有的) 

- 将master的 ca配置文件 拷贝到 node 节点 (master节点上操作)
```
[root@hz01-online-ops-openmasteretc-01 /opt]# cd /etc/origin/master/
[root@hz01-online-ops-openmasteretc-01 /etc/origin/master]# scp ca.crt ca.key ca.serial.txt openshift-node1:/etc/origin/node/
```
- 在node节点上 生成配置(node节点上操作)

```
oc adm create-node-config \
--node-dir=/etc/origin/node \
--node=hz01-online-ops-opennode-01 \
--hostnames=hz01-online-ops-opennode-01,172.16.8.104 \
--certificate-authority="/etc/origin/node/ca.crt"   \
--signer-cert="/etc/origin/node/ca.crt"   \
--signer-key="/etc/origin/node/ca.key"   \
--signer-serial="/etc/origin/node/ca.serial.txt" \
--node-client-certificate-authority="/etc/origin/node/ca.crt" \
--network-plugin="redhat/openshift-ovs-subnet" \
--dns-ip='172.30.0.1' \
--master='https://openshift.ops.com'
```
注意: 如下设置要改成对应计算节点的信息 
```
--node=hz01-online-ops-opennode-01 \
--hostnames=hz01-online-ops-opennode-01,172.16.8.104\
```

脚本如下:
```
# cat addnode.sh 
#!/bin/bash
NODE_NAME=`hostname`
NODE_IP=`ifconfig eth0 |grep '172' |awk '{print $2}'`

oc adm create-node-config \
    --node-dir=/etc/origin/node \
    --node=$NODE_NAME \
    --hostnames=$NODE_NAME,$NODE_IP \
    --certificate-authority="/etc/origin/node/ca.crt"   \
    --signer-cert="/etc/origin/node/ca.crt"   \
    --signer-key="/etc/origin/node/ca.key"   \
    --signer-serial="/etc/origin/node/ca.serial.txt" \
    --node-client-certificate-authority="/etc/origin/node/ca.crt" \
    --network-plugin="redhat/openshift-ovs-subnet" \
    --dns-ip='172.30.0.1' \
    --master='https://openshift.ops.com'
```


- 启动node节点(确保openshhift.ops.com能够解析或者hosts绑定)

```
[root@hz01-online-ops-opennode-01 /opt]# systemctl enable origin-node
[root@hz01-online-ops-opennode-01 /opt]# systemctl start origin-node
```

- 检查日志和到服务端确认node注册成功

```
[root@hz01-online-ops-openmasteretc-01 /etc/origin/master]# oc get node
NAME                          STATUS    AGE       VERSION
hz01-online-ops-opennode-01   Ready     12s       v1.6.1+5115d708d7

[root@hz01-online-ops-openmasteretc-01 /etc/origin/master]# oc get hostsubnet
NAME                          HOST                          HOST IP        SUBNET
hz01-online-ops-opennode-01   hz01-online-ops-opennode-01   172.16.8.104   10.128.0.0/23
```
