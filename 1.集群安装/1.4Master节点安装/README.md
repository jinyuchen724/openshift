| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 部署主机角色说明

| 主机角色 | IP地址 |   负载域名 |
| ---      | -----  |   ---  |
| 管理节点(Master)  | openshift-master1(192.168.124.22) | openshift.ops.com |
| 管理节点(Master)  | openshift-master2(192.168.124.23) | openshift.ops.com |
| 管理节点(Master)  | openshift-master3(192.168.124.24) | openshift.ops.com |


## 安装前基础环境检查
### 配置仓库源(如果自己建立本地源 直接跳过本步骤)

- 安装仓库源文件

```
yum install centos-release-openshift-origin.noarch
```

- 修改仓库配置 指向 V3.6版本(默认是指向最新的版本)

```
[root@openshift-master ~]# cat /etc/yum.repos.d/CentOS-OpenShift-Origin.repo
[centos-openshift-origin]
name=CentOS OpenShift Origin
baseurl=http://mirrors.163.com/centos/7/paas/x86_64/openshift-origin36/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-PaaS
其他省略。。。。。。。。
```
主要是把 
**http://mirror.centos.org/centos/7/paas/x86_64/openshift-origin/**
修改为下面链接(使用163镜像)
**http://mirrors.163.com/centos/7/paas/x86_64/openshift-origin36/**

## 安装第一个master节点软件包

- 安装 origin-master

```
yum install  origin-master -y
```
- 由于yum安装的master节点的证书不包含对外负载域名(openshift.ops.com),所以需要重新签发证书,并删除默认node配置

```
openshift start master --public-master='https://openshift.ops.com'   --network-plugin='redhat/openshift-ovs-subnet' --write-config=/etc/origin/master
rm -fr /etc/origin/node
```
- 查看证书生成的信息,DNS中会生成一个openshift.ops.com的域名

```
[root@openshift-master master]# openssl x509 -noout -text -in  master.server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 11 (0xb)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=openshift-signer@1524139430
        Validity
            Not Before: Apr 19 12:06:27 2018 GMT
            Not After : Apr 18 12:06:28 2020 GMT
        Subject: CN=127.0.0.1
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b1:93:7c:57:d5:e1:c1:2c:59:1a:28:9e:b0:df:
                    38:cc:de:ab:d3:ab:6a:fa:97:3a:f2:79:80:26:0b:
                    f0:92:7f:e3:e8:be:da:37:43:d0:f6:ce:d9:c1:e0:
                    a5:cb:cf:af:04:bb:a4:bc:84:2c:a4:97:08:d4:c1:
                    a5:d5:48:4f:3a:96:fb:2e:66:ad:6e:1f:d1:4a:8d:
                    21:c4:68:3d:f2:79:e2:3e:c5:e1:ee:78:2b:63:96:
                    d7:fa:f2:e8:b4:58:45:1c:ba:6c:ca:0f:4b:b3:cf:
                    26:95:43:fe:fa:43:88:a4:48:c7:4e:07:83:66:eb:
                    fe:48:78:f2:07:24:7c:a8:f4:6f:7b:80:5a:7e:7d:
                    0f:b2:87:46:5b:76:05:e2:d3:f0:58:87:69:64:5a:
                    17:91:70:6f:81:90:89:ac:65:57:cc:f2:67:8b:c7:
                    26:0d:79:b7:84:3f:58:ec:5c:d7:a2:85:17:36:e8:
                    62:86:6d:3d:21:43:38:cf:1c:2c:c4:c9:3d:6c:b4:
                    da:c3:0c:5e:ca:3f:74:ff:b7:39:1e:fb:63:bf:47:
                    66:54:54:8f:88:c3:8f:ba:a5:dd:70:ec:53:6a:ce:
                    49:48:77:1a:10:cc:81:bb:85:a4:55:b7:07:e9:fa:
                    7c:67:38:40:35:1c:bf:cf:ee:45:79:19:6b:69:45:
                    3d:0b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Alternative Name:
                DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, DNS:localhost, DNS:openshift, DNS:openshift.default, DNS:openshift.default.svc, DNS:openshift.default.svc.cluster.local, DNS:openshift.ops.com, DNS:127.0.0.1, DNS:172.30.0.1, DNS:192.168.124.22, IP Address:127.0.0.1, IP Address:172.30.0.1, IP Address:192.168.124.22
    Signature Algorithm: sha256WithRSAEncryption
         d5:8b:11:66:64:0e:cc:b9:36:85:15:1f:75:02:d1:9b:5c:32:
         b5:af:1e:d9:38:85:e0:95:77:d7:5d:42:dd:e9:40:07:c8:d2:
         ae:4b:99:db:8f:61:49:e7:3b:37:4b:22:cc:0b:07:5d:6a:39:
         ce:82:e8:00:38:4e:af:14:1b:9c:78:6a:2e:58:b8:44:c0:62:
         96:18:7d:58:2c:9c:db:87:e3:47:20:61:97:7f:ae:3f:74:c5:
         4a:cc:88:e6:6b:1b:4c:b4:16:6d:66:99:4a:7f:bc:51:ec:b4:
         17:66:56:ab:d5:16:0f:a8:2b:8b:5c:dc:91:e1:bc:3b:99:41:
         5b:ad:cb:f0:52:20:23:93:46:44:de:cf:fe:70:27:ec:8d:eb:
         65:23:84:5d:cb:75:18:31:19:d9:0d:8c:43:0b:6f:c7:97:1e:
         02:41:d9:07:93:bb:b0:dc:53:08:54:0e:48:cc:1c:60:4d:87:
         c2:a8:be:56:55:af:53:62:21:29:2b:43:eb:38:45:f9:11:52:
         b6:d8:56:77:3d:a0:34:1c:69:3b:e1:3d:f9:85:46:f9:60:b9:
         2e:b4:b2:e2:54:a7:20:7a:a3:50:de:38:ad:4b:31:e3:45:2c:
         45:3a:b6:8c:a3:5f:80:47:97:f9:e8:2f:e6:b8:2d:11:55:3d:
         0a:6a:fc:18
```

- 修改master etcd配置,使用前面配置好的etcd集群

修改前

```
[root@openshift-master master]# cat /etc/origin/master/master-config.yaml
.....省略.....
etcdClientInfo:
  ca: ca.crt
  certFile: master.etcd-client.crt
  keyFile: master.etcd-client.key
  urls:
  - https://192.168.124.22:4001
etcdConfig:
  address: 192.168.124.22:4001
  peerAddress: 192.168.124.22:7001
  peerServingInfo:
    bindAddress: 0.0.0.0:7001
    bindNetwork: tcp4
    certFile: etcd.server.crt
    clientCA: ca.crt
    keyFile: etcd.server.key
    namedCertificates: null
  servingInfo:
    bindAddress: 0.0.0.0:4001
    bindNetwork: tcp4
    certFile: etcd.server.crt
    clientCA: ca.crt
    keyFile: etcd.server.key
    namedCertificates: null
  storageDirectory: /etc/origin/openshift.local.etcd
etcdStorageConfig:
  kubernetesStoragePrefix: kubernetes.io
  kubernetesStorageVersion: v1
  openShiftStoragePrefix: openshift.io
  openShiftStorageVersion: v1
.....省略.....
```

修改后

```
[root@openshift-master master]# cat /etc/origin/master/master-config.yaml
.....省略.....
etcdClientInfo:
  ca: master.etcd-ca.crt
  certFile: master.etcd-client.crt
  keyFile: master.etcd-client.key
  urls:
    - https://192.168.124.22:2379
    - https://192.168.124.23:2379
    - https://192.168.124.24:2379
etcdStorageConfig:
  kubernetesStoragePrefix: kubernetes.io
  kubernetesStorageVersion: v1
  openShiftStoragePrefix: openshift.io
  openShiftStorageVersion: v1
.....省略.....
```

- openshift配置与etcd的证书对应关系

|openshift证书名|etcd证书名|
|---|---|
| master.etcd-ca.crt|etcd-root-ca.pem|
|master.etcd-client.crt|etcd.pem|
|master.etcd-client.key|etcd-key.pem|

- 拷贝相关证书到master目录

```
[root@openshift-master master]# cat /etc/origin/master/master-config.yaml ^C
[root@openshift-master master]# cp /etc/etcd/etcd-root-ca.pem /etc/origin/master/master.etcd-ca.crt
[root@openshift-master master]# cp /etc/etcd/etcd.pem /etc/origin/master/master.etcd-client.crt
cp: overwrite ‘/etc/origin/master/master.etcd-client.crt’? y
[root@openshift-master master]# cp /etc/etcd/etcd-key.pem /etc/origin/master/master.etcd-client.key
cp: overwrite ‘/etc/origin/master/master.etcd-client.key’? y
```

- 启动master

```
systemctl enable origin-master.service
systemctl start origin-master.service
```

### 权限登录配置

#### 超级admin用户登陆配置说明(只能命令行登陆)

- admin 用户登陆使用密钥文件

```
/etc/origin/master/admin.kubeconfig
```

- 管理员登陆 使用证书密钥进行管理(当前用户是root)

```
[root@openshift-master ~]# mkdir -p /root/.kube
[root@openshift-master ~]# cp /etc/origin/master/admin.kubeconfig    /root/.kube/config
[root@openshift-master ~]# oc login -u system:admin
Logged into "https://192.168.124.22:8443" as "system:admin" using existing credentials.

You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default
    kube-public
    kube-system
    openshift
    openshift-infra

Using project "default".
```

- 执行 如下命令可以看到当前登录用户

```
[root@openshift-master ~]# oc whoami
system:admin
```
### WEBUI 登陆用户配置

- 安装完默认是任意密码登陆，这里配置htpasswd方式进行认证

修改前
```
    provider:
      apiVersion: v1
      kind: AllowAllPasswordIdentityProvider
```
修改后

```
    provider:
      apiVersion: v1
      kind: HTPasswdPasswordIdentityProvider
      file: /etc/origin/master/htpasswd
```

- 安装htpasswd

```
[root@openshift-master master]# yum install httpd-tools -y
```

- 添加ops账户

```
[root@openshift-master master]# htpasswd -c /etc/origin/master/htpasswd ops
New password:
Re-type new password:
Adding password for user ops
```

- 将ops用户加入openshift-infra 和 default 项目，并赋予admin权限

```
[root@openshift-master master]# oc adm policy add-role-to-user admin ops -n openshift-infra
role "admin" added: "ops"
[root@openshift-master master]# oc adm policy add-role-to-user admin ops -n default
role "admin" added: "ops"
```

- 重启master 节点

```
systemctl daemon-reload
systemctl restart origin-master
```

至此 第一个master节点安装部署完成

## 其他2个master节点安装

- 参考第一个节点,配置仓库,安装 origin-master 软件包

- 将第一个master节点的 ca配置和相关配置文件拷贝到其他master节点上
```
scp ca.* master.etcd-* htpasswd openshift-master2:/etc/origin/master
```

- 在其他2个节点重新生成配置
```
openshift start master --public-master='https://openshift.ops.com'   --network-plugin='redhat/openshift-ovs-subnet' --write-config=/etc/origin/master
```

- 参考上文设置 超级admin用户登陆配置

- 启动master节点即可

- 检查日志,无错误,安装完成
