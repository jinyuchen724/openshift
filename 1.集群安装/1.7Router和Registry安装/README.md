| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 部署主机角色说明

| 主机角色 | IP地址 |  节点标签  | 域名 |
| ---      | -----  |  ---  | ---  |
| 基础设施节点(Node) | hz01-online-ops-opennode-01（172.16.8.104) | zone=ops | *.open-prod.ops.com |


说明:<br> 
router 组件是用户访问的入口，域名都需要指向Router组件所在运行的计算节点上

registry组件是openshift集群内部使用的docker仓库,主要存放源代码打包生成的镜像

## 部署 Router 组件

- 给Node节点打标签

```
[root@hz01-online-ops-openmasteretc-01 /root]# oc label node hz01-online-ops-opennode-01 zone=ops
node "openshift-node1" labeled
[root@hz01-online-ops-openmasteretc-01 /root]# oc get node --show-labels 
NAME                          STATUS    AGE       VERSION             LABELS
hz01-online-ops-opennode-01   Ready     20m       v1.6.1+5115d708d7   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=hz01-online-ops-opennode-01,zone=ops
hz01-online-ops-opennode-02   Ready     19m       v1.6.1+5115d708d7   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=hz01-online-ops-opennode-02
hz01-online-ops-opennode-03   Ready     3m        v1.6.1+5115d708d7   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=hz01-online-ops-opennode-03

```
通过对Node节点打标签，在部署组件的时候，可以指定部署到特定节点上

- 建立一个 service account 关联router 并赋予权限

```
[root@hz01-online-ops-openmasteretc-01 /root]# oc project default
[root@hz01-online-ops-openmasteretc-01 /root]# oadm policy add-scc-to-user privileged system:serviceaccount:default:router
[root@hz01-online-ops-openmasteretc-01 /root]# oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:router
cluster role "cluster-reader" added: "system:serviceaccount:default:router"
```
- 创建一个名为 router01 的实例，在指定的计算节点上

```
[root@hz01-online-ops-openmasteretc-01 /root]# oadm router router01 --replicas=1 --service-account=router --selector='zone=ops'
info: password for stats user admin has been set to iC3sKtFY5k
--> Creating router router01 ...
    serviceaccount "router" created
    clusterrolebinding "router-router01-role" created
    deploymentconfig "router01" created
    service "router01" created
--> Success

查看状态
[root@hz01-online-ops-openmasteretc-01 /root]# oc get pod -n default
NAME                READY     STATUS              RESTARTS   AGE
router01-1-deploy   0/1       ContainerCreating   0          1m
正在下载docker images  过几分钟再看(取决于下载速度)
[root@hz01-online-ops-openmasteretc-01 /root]# oc get pod -n default
NAME               READY     STATUS    RESTARTS   AGE
router01-1-hvc1j   1/1       Running   0          1m
```

## 部署registry
```
[root@hz01-online-ops-openmasteretc-01 /root]# oadm registry --config=/etc/origin/master/admin.kubeconfig  --service-account=registry --selector='zone=ops'
--> Creating registry registry ...
    serviceaccount "registry" created
    clusterrolebinding "registry-registry-role" created
    deploymentconfig "docker-registry" created
    service "docker-registry" created
--> Success
[root@hz01-online-ops-openmasteretc-01 /root]# oc get pod
NAME                       READY     STATUS              RESTARTS   AGE
docker-registry-1-deploy   0/1       ContainerCreating   0          3s
router01-1-hvc1j           1/1       Running             0          14h
[root@hz01-online-ops-openmasteretc-01 /root]# oc get pod
NAME                      READY     STATUS    RESTARTS   AGE
docker-registry-1-k5zq1   1/1       Running   0          3m
router01-1-hvc1j          1/1       Running   0          14h
```
## 查看各个SERVICE的内部集群地址
```
[root@hz01-online-ops-openmasteretc-01 /root]# oc get svc
NAME              CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
docker-registry   172.30.111.126   <none>        5000/TCP                  9m
kubernetes        172.30.0.1       <none>        443/TCP,53/UDP,53/TCP     22h
router01          172.30.121.139   <none>        80/TCP,443/TCP,1936/TCP   15h
```
注意: 172.30.0.0/16 这个段是 cluster ip,如果容器出现问题或者迁移，这个 cluster ip 是不会改变的 


