| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## Openshift  Origin v3.6 架构图

OpenShift 是一款容器应用平台，它将 Docker 和 Kubernetes 技术带入企业。

 ![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/architecture_overview.png)
 
上图是openshift origin 总体架构图

![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/openshift_k8s.jpg)

上图是 openshift 和 k8s 所在容器云平台的关系

## 主服务和计算节点关系结构

![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/all_in_one.png)

![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/master-node.jpg)

**主服务器(Masters)依赖于基于etcd的分布式目录， 主要用来提供配置共享和服务发现**

**计算节点(Nodes) 主要用来作为PODS的宿主和运行容器**

## 整体应用概念介绍

![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/openshift-app2.jpg)

![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/opensift_app.png)

![image](https://github.com/jinyuchen724/openshift/raw/master/1.集群安装/1.1架构介绍/k8s_arch.jpg)

上述应用架构图中， 概念来源于Kubernetes的概念， 需要明白以下主要的对象。

- 一个 **POD** 是一个Docker 容器的运行环境(如果需要共享本地的资源， 我们将在单独的POD中布署两种类别的容器)
- 一个 **Service** 服务是一个入口(VIP)，抽象出一个均衡访问负载到一组相同的容器，理论上， 最少是一个服务对应一个架构层
- 一个服务布署者(**Service Deployer**)或布署配置(**Deployment Config**)是一个对象， 用来描述基于触发器的容器的布署策略(比如，当docker仓库中有新版本的映象时， 重新布署)
- 一个复制控制器(**Replication Controller**)是一个技术组件， 主要负责POD 的弹性。
- 一个路由(**Route**)是用来暴露一个应用的入口(域名解析， 主机名或VIP)
