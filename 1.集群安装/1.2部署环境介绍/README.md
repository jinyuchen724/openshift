| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## Openshift v3.6 高可用部署架构图

![image](https://github.com/jinyuchen724/openshift/raw/master/架构介绍/openshift_HA.png)

* **Masters Node** 负载均衡使用 **HAPROXY** 做基于tcp模式的负载(SSL证书穿透)
* **Data Store** 是使用etcd作为信息的存储数据库
* **Infrastructure Node** 基础设施节点,用于运行平台自身的管理服务(route,docker仓库,度量数据,日志数据等),也可以定义一些其他功能节点
  比如**ops Node** 主要运维相关的服务(zabbix,cmdb,ticket等),**dev Node** 主要运行研发相关服务(maven镜像库,gitlab,go-cd等)
* **Persistent Storage** 持久卷这里使用的是 **CEPH https://ceph.com/** 分布式文件系统
* 操作系统发行版本使用的是 CENTOS 7


## 部署主机角色说明

| 主机角色 | IP地址 | 操作系统 | 摘要 | 域名 |
| ---      | -----  | -------- | ---  | ---  |
| 管理节点(Master)  | openshift-master1(192.168.124.22) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + etcd + haproxy | openshift.ops.com |
| 管理节点(Master)  | openshift-master2(192.168.124.23) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + etcd | openshift.ops.com |
| 管理节点(Master)  | openshift-master3(192.168.124.24) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + etcd | openshift.ops.com |
| 基础设施节点(Node) | openshift-node1（192.168.124.30） | CentOS Linux release 7.3.1611 (Core) X86-64 | router + registry | lb.openshift.ops.com |
| 计算节点(Node) | openshift-node2（192.168.124.46） | CentOS Linux release 7.3.1611 (Core) X86-64 | 计算节点 | 无对外域名 |

 **注：本环境中 master节点的负载均衡haproxy 示例没有配置2个节点,如需要,可以参考互联网上 haproxy + keeplived 方式实现**

## 域名设置说明


| 域名角色 | 通配域名(泛域名) | CNAME地址 |
| ------   | -------------    | --------  |
| 开发环境域名 | *.dev.openshift.ops.com | lb.openshift.ops.com |
| 测试环境域名 | *.test.openshift.ops.com | lb.openshift.ops.com |
| 生产环境域名 | *.prod.openshift.ops.com | lb.openshift.ops.com |
 **注：这里为每个环境都配置范域名解析,都指向 router 所在的计算节点上,如果没有配置DNS,做hosts绑定域名也可以**

{{% notice note %}}
但是 master的高可用负载域名 **openshift.ops.com**(指向haproxy) 在master节点所配置的dns必须能够解析,hosts绑定是无效的,
原因是计算节点运行的容器内部 /etc/resolve.conf dns是指向master节点的,如果容器内需要访问 **openshift.ops.com** 这个域名就会forward 主服务节点配置的dns上
{{% /notice %}}