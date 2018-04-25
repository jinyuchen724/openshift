+++
title = "EFK日志系统安装"
date =  2018-03-30T01:46:28-04:00
weight = 9
keywords = "openshift node,架构,docker,部署环境,metric"
+++

| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |



## 部署日志采集服务

- 因为每个节点都需要采集日志，所以新建的logging项目选择的标签为空。
```
[root@hz01-prod-ops-openshiftmaster-01 /]# oc adm new-project  logging --node-selector=""  
```

- 修改ansible配置文件

```
cat /etc/ansible/log_hosts
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=root
openshift_deployment_type=origin
openshift_logging_install_logging=True
openshift_logging_image_version=v3.6.1
openshift_logging_kibana_hostname=kibana.ops.com
#The URL for the Kubernetes master, this does not need to be public facing but should be accessible from within the cluster.
#default is https://kubernetes.default.svc.cluster.local
#openshift_logging_master_url=https://openshift.ops.com
#The public facing URL for the Kubernetes master. This is used for Authentication redirection by the Kibana proxy.
openshift_logging_master_public_url=https://openshift.ops.com
openshift_logging_es_memory_limit=1G
[masters]
openshift-master

[nodes]
openshift-node1
openshift-node2
```

- 执行安装日志采集服务
```
ansible-playbook -i /etc/ansible/log_hosts /opt/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml 
```

- 确认部署是否成功
```
[root@hz01-prod-ops-openshiftmaster-01 /root]
# oc get pod
NAME                                      READY     STATUS    RESTARTS   AGE
logging-curator-1-01khs                   1/1       Running   0          1d
logging-es-data-master-f9r7g76t-1-bpvkq   1/1       Running   0          1d
logging-fluentd-05cr8                     1/1       Running   0          1d
logging-fluentd-wc8ht                     1/1       Running   0          1d
logging-kibana-1-h4rl1                    2/2       Running   0          1d
```

至此集中日志功能部署完成

## 可能碰到的问题

- log-es 集群启动会出现如下错误(通过 oc logs 查看)

```
[2017-11-01 15:10:02,491][INFO ][container.run            ] Begin Elasticsearch startup script
--
  | [2017-11-01 15:10:02,498][INFO ][container.run            ] Comparing the specified RAM to the maximum recommended for Elasticsearch...
  | [2017-11-01 15:10:02,499][INFO ][container.run            ] Inspecting the maximum RAM available...
  | [2017-11-01 15:10:02,503][INFO ][container.run            ] ES_HEAP_SIZE: '4096m'
  | [2017-11-01 15:10:02,506][INFO ][container.run            ] Setting heap dump location /elasticsearch/persistent/heapdump.hprof
  | [2017-11-01 15:10:02,509][INFO ][container.run            ] Checking if Elasticsearch is ready on https://localhost:9200
  | Exception in thread "main" java.lang.IllegalArgumentException: Unknown Discovery type [kubernetes]
  | at org.elasticsearch.discovery.DiscoveryModule.configure(DiscoveryModule.java:100)
  | at <<<guice>>>
  | at org.elasticsearch.node.Node.<init>(Node.java:213)
  | at org.elasticsearch.node.Node.<init>(Node.java:140)
  | at org.elasticsearch.node.NodeBuilder.build(NodeBuilder.java:143)
  | at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:194)
  | at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:286)
  | at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:45)
  | Refer to the log for complete error details.
```

这个有2中解决方法

1. 将ansible的host配置文中中  **openshift_logging_image_version=v3.6.1** 改为 **openshift_logging_image_version=latest**

1. 修改已有的 dc(部署配置) **oc edit dc/logging-es-data-master-we71py7f**

将如下行 
```
image: docker.io/openshift/origin-logging-elasticsearch:latest 
```
变更成
```
image: docker.io/openshift/origin-logging-elasticsearch:v3.6
```
原因是请查看 https://hub.docker.com/r/openshift/origin-logging-elasticsearch/tags/  v3.6 与 v3.6.1 相比,从更新时间上来说 **v3.6** 属于最新版本
