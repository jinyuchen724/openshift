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
openshift_logging_kibana_hostname=kibana.open-prod.ops.com
#The URL for the Kubernetes master, this does not need to be public facing but should be accessible from within the cluster.
#default is https://kubernetes.default.svc.cluster.local
#openshift_logging_master_url=https://openshift.ops.com
#The public facing URL for the Kubernetes master. This is used for Authentication redirection by the Kibana proxy.
openshift_logging_master_public_url=https://openshift.ops.com
openshift_logging_es_memory_limit=1G

[masters]
hz01-online-ops-openmasteretc-01
hz01-online-ops-openmasteretc-02
hz01-online-ops-openmasteretc-03
[nodes]
hz01-online-ops-opennode-01
hz01-online-ops-opennode-02
hz01-online-ops-opennode-03
```

- 执行安装日志采集服务
```
ansible-playbook -i /etc/ansible/log_hosts /opt/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml 
```

- 确认部署是否成功
```
[root@hz01-prod-ops-openshiftmaster-01 /root]# oc get pod
NAME                                      READY     STATUS    RESTARTS   AGE
logging-curator-1-01khs                   1/1       Running   0          1d
logging-es-data-master-f9r7g76t-1-bpvkq   1/1       Running   0          1d
logging-fluentd-05cr8                     1/1       Running   0          1d
logging-fluentd-wc8ht                     1/1       Running   0          1d
logging-kibana-1-h4rl1                    2/2       Running   0          1d
```

至此集中日志功能部署完成

{{% notice note %}} The logs for the default,openshift, and openshift-infra projects are automatically aggregated and grouped into the .operations item in the Kibana interface. The project where you have deployed the EFK stack (logging, as documented here) is not aggregated into .operations and is found under its ID.
If you set openshift_logging_use_ops to true in your inventory file, Fluentd is configured to split logs between the main Elasticsearch cluster and another cluster reserved for operations logs, which are defined as node system logs and the projects default, openshift, and openshift-infra. {{% /notice %}}

注意: 这里没有配置ops集群,所以基础系统项目的日志从kibana ui上是看不到的

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

```
[root@hz01-online-ops-openmasteretc-01 /root]
# oc logs po/logging-curator-1-deploy 
--> Scaling logging-curator-1 to 1
--> Error listing events for replication controller logging-curator-1: Get https://172.30.0.1:443/api/v1/namespaces/logging/events?fieldSelector=involvedObject.kind%3DReplicationController%2CinvolvedObject.name%3Dlogging-curator-1%2CinvolvedObject.namespace%3Dlogging%2CinvolvedObject.uid%3D8c9c7209-4ad6-11e8-bfd6-0607bc000482: dial tcp 172.30.0.1:443: getsockopt: connection refused
error: couldn't scale logging-curator-1 to 1: watch closed before Until timeout

[root@hz01-online-ops-openmasteretc-01 /root]# oc edit dc/logging-curator
image: docker.io/openshift/origin-logging-curator:v3.6.1 
改成
image: docker.io/openshift/origin-logging-curator:v3.6
```



### 查看es索引情况

进入容器
```
oc rsh logging-es-data-master-bhbc13z0-1-hv85d 
```

查看索引(.operations.* 索引存放的是系统日志)

```
sh-4.2$ curl -s --cacert /etc/elasticsearch/secret/admin-ca --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key --max-time 30 https://localhost:9200/_cat/indices?v
health status index                                                           pri rep docs.count docs.deleted store.size pri.store.size
green  open   .kibana                                                           1   0          1            0      3.1kb          3.1kb
green  open   .searchguard.logging-es-data-master-im3sye06                      1   0          5            0       32kb           32kb
green  open   project.cboard.0f516fc0-4870-11e8-86f9-06d28000000c.2018.04.25    1   0       6914            0      2.8mb          2.8mb
green  open   project.cboard.0f516fc0-4870-11e8-86f9-06d28000000c.2018.04.26    1   0       1328            0    711.9kb        711.9kb
green  open   project.logging.4abce3a2-4618-11e8-9d6b-06d28000000c.2018.04.25   1   0       7550            0      4.2mb          4.2mb
green  open   project.logging.4abce3a2-4618-11e8-9d6b-06d28000000c.2018.04.26   1   0       1434            0    993.1kb        993.1kb
green  open   .operations.2018.04.26                                            1   0       3129            0      1.5mb          1.5mb
green  open   .kibana.a94a8fe5ccb19ba61c4c0873d391e987982fbbd3                  1   0          2            0     26.2kb         26.2kb
green  open   .operations.2018.04.25                                            1   0      16708            0      8.4mb          8.4mb
green  open   .kibana.c62973cc56845b0e473e9e3c40b6e1f0a84662ef                  1   0          2            0     26.2kb         26.2kb
```

查看系统日志 2018.04.26

```
sh-4.2$ curl -s --cacert /etc/elasticsearch/secret/admin-ca --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key --max-time 30 https://localhost:9200/.operations.2018.04.26/_search
```
