| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## ETCD证书

- etcd集群信息

| 主机名 | IP地址 | 操作系统 | etcd版本 |
| ---    | -----  |  --- | -------  |
| hz01-online-ops-openmasteretc-01 | 172.16.8.40 | CentOS Linux release 7.3.1611 (Core) x86_64 | etcd-3.2.7-1.el7.x86_64 |
| hz01-online-ops-openmasteretc-02 | 172.16.8.84 | CentOS Linux release 7.3.1611 (Core) x86_64 | etcd-3.2.7-1.el7.x86_64 |
| hz01-online-ops-openmasteretc-03 | 172.16.8.41 | CentOS Linux release 7.3.1611 (Core) x86_64 | etcd-3.2.7-1.el7.x86_64 |


- 证书生成

| 证书名称 | 配置文件 | 用途 |
| --- | ----- | ----- | 
|etcd-root-ca.pem |etcd-root-ca-csr.json |etcd 根 CA 证书 |
|etcd.pem|etcd-gencert.json、etcd-csr.json|etcd 集群证书 |

- CFSSL 工具安装
首先下载 cfssl，并给予可执行权限，然后扔到 PATH 目录下

```
[root@hz01-online-ops-openmasteretc-01 /opt]# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
[root@hz01-online-ops-openmasteretc-01 /opt]# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
[root@hz01-online-ops-openmasteretc-01 /opt]# chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
[root@hz01-online-ops-openmasteretc-01 /opt]# mv cfssl_linux-amd64 /usr/local/bin/cfssl
[root@hz01-online-ops-openmasteretc-01 /opt]# mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
```

- Etcd 证书生成所需配置文件如下:

```
[root@hz01-online-ops-openmasteretc-01 /opt]# cat etcd-root-ca-csr.json 
{
   "key": {
     "algo": "rsa",
     "size": 4096
   },
   "names": [
     {
       "O": "etcd",
       "OU": "etcd Security",
       "L": "Beijing",
       "ST": "Beijing",
       "C": "CN"
     }
   ],
   "CN": "etcd-root-ca"
}

[root@hz01-online-ops-openmasteretc-01 /opt]# cat etcd-gencert.json 
{
  "signing": {
    "default": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "87600h"
    }
  }
}

[root@hz01-online-ops-openmasteretc-01 /opt]# cat etcd-csr.json 
{
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "O": "etcd",
      "OU": "etcd Security",
      "L": "Beijing",
      "ST": "Beijing",
      "C": "CN"
    }
  ],
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "localhost",
    "172.16.8.40",
    "172.16.8.84",
    "172.16.8.41",
    "hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com",
    "hz01-online-ops-openmasteretc-02.sysadmin.xinguangnet.com",
    "hz01-online-ops-openmasteretc-03.sysadmin.xinguangnet.com",
    "openshift.ops.com"
  ]
}
```
**注意: hosts 要将 etcd 集群的所在节点的 IP地址,主机名(FQDN),都要加入到此列表中**

- 生成 Etcd 证书

```
[root@hz01-online-ops-openmasteretc-01 /opt]# cfssl gencert --initca=true etcd-root-ca-csr.json | cfssljson --bare etcd-root-ca
[root@hz01-online-ops-openmasteretc-01 /opt]# cfssl gencert --ca etcd-root-ca.pem --ca-key etcd-root-ca-key.pem --config etcd-gencert.json etcd-csr.json | cfssljson --bare etcd

#生成的证书列表如下
[root@hz01-online-ops-openmasteretc-01 /opt]# ll 
总用量 36
-rw-r--r-- 1 root root 2033 3月  27 18:09 etcd.csr
-rw-r--r-- 1 root root  513 3月  27 18:09 etcd-csr.json
-rw-r--r-- 1 root root  204 3月  27 18:08 etcd-gencert.json
-rw------- 1 root root 3247 3月  27 18:09 etcd-key.pem
-rw-r--r-- 1 root root 2415 3月  27 18:09 etcd.pem
-rw-r--r-- 1 root root 1708 3月  27 18:09 etcd-root-ca.csr
-rw-r--r-- 1 root root  232 3月  27 18:07 etcd-root-ca-csr.json
-rw------- 1 root root 3243 3月  27 18:09 etcd-root-ca-key.pem
-rw-r--r-- 1 root root 2078 3月  27 18:09 etcd-root-ca.pem
```

## 部署 ETCD 集群

### 第一个节点etcd1 安装

- 安装etcd，并将证书拷贝安装目录，赋权

```
[root@hz01-online-ops-openmasteretc-01 /opt]# yum install etcd -y
[root@hz01-online-ops-openmasteretc-01 /opt]# cp *.pem /etc/etcd/
[root@hz01-online-ops-openmasteretc-01 /opt]# chown -R etcd:etcd /etc/etcd/
[root@hz01-online-ops-openmasteretc-01 /opt]# chmod -R 755 /etc/etcd/
```

- 配置内容

```
[root@hz01-online-ops-openmasteretc-01 /opt]# cat /etc/etcd/etcd.conf
#[member]
ETCD_NAME=hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com
ETCD_DATA_DIR="/var/lib/etcd/"
ETCD_HEARTBEAT_INTERVAL=500
ETCD_ELECTION_TIMEOUT=2500
ETCD_LISTEN_PEER_URLS="https://172.16.8.40:2380"
ETCD_LISTEN_CLIENT_URLS="https://172.16.8.40:2379,http://127.0.0.1:2379"
ETCD_MAX_SNAPSHOTS="5"
ETCD_MAX_WALS="5"
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.16.8.40:2380"
#if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="hz01-online-ops-openmasteretc-01.sysadmin.xinguangnet.com=https://172.16.8.40:2380,hz01-online-ops-openmasteretc-02.sysadmin.xinguangnet.com=https://172.16.8.84:2380,hz01-online-ops-openmasteretc-03.sysadmin.xinguangnet.com=https://172.16.8.41:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://172.16.8.40:2379"
# [security]
ETCD_CERT_FILE="/etc/etcd/etcd.pem"
ETCD_KEY_FILE="/etc/etcd/etcd-key.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE="/etc/etcd/etcd-root-ca.pem"
ETCD_AUTO_TLS="true"
ETCD_PEER_CERT_FILE="/etc/etcd/etcd.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/etcd-key.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/etcd-root-ca.pem"
ETCD_PEER_AUTO_TLS="true"
```

- 启动服务

```
[root@hz01-online-ops-openmasteretc-01 /opt]# systemctl enable etcd
[root@hz01-online-ops-openmasteretc-01 /opt]# systemctl start etcd
```

### 其他2个节点安装

- 安装 etcd 软件包

```
[root@hz01-online-ops-openmasteretc-02 /opt]# yum install etcd -y
```
- 将第一个节点的配置拷贝到其他2个节点

```
[root@hz01-online-ops-openmasteretc-01 /opt]# cd /etc/etcd/
[root@hz01-online-ops-openmasteretc-01 /opt]# ll
total 20
-rwxr-xr-x 1 etcd etcd  920 Apr 18 06:11 etcd.conf
-rwxr-xr-x 1 etcd etcd 3243 Apr 18 06:07 etcd-key.pem
-rwxr-xr-x 1 etcd etcd 2167 Apr 18 06:07 etcd.pem
-rwxr-xr-x 1 etcd etcd 3247 Apr 18 06:07 etcd-root-ca-key.pem
-rwxr-xr-x 1 etcd etcd 2078 Apr 18 06:07 etcd-root-ca.pem
[root@hz01-online-ops-openmasteretc-01 /opt]# scp * openshift-master2:/etc/etcd/
etcd.conf                                     100%  920     0.9KB/s   00:00
etcd-key.pem                                  100% 3243     3.2KB/s   00:00
etcd.pem                                      100% 2167     2.1KB/s   00:00
etcd-root-ca-key.pem                          100% 3247     3.2KB/s   00:00
etcd-root-ca.pem                              100% 2078     2.0KB/s   00:00
```
- 在其他2个节点上修改如下配置项,ip地址改成本节点的对应的IP地址

```
ETCD_LISTEN_PEER_URLS="https://172.16.8.84:2380"
ETCD_LISTEN_CLIENT_URLS="https://172.16.8.84:2379,http://127.0.0.1:237/"
#ETCD节点名称 按顺序增加即可
ETCD_NAME=hz01-online-ops-openmasteretc-02.sysadmin.xinguangnet.com
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.16.8.84:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://172.16.8.84:2379"
```

- 启动服务即可

## 验证(3个节点都安装配置完成后)

```
[root@openshift-master etcd]# export ETCDCTL_API=3
[root@openshift-master etcd]# etcdctl member list
2da38978bc038ba1, started, etcd1, https://192.168.124.22:2380, https://192.168.124.22:2379
56e71904a9636fcf, started, etcd0, https://192.168.124.23:2380, https://192.168.124.23:2379
faf6915e4bb01350, started, etcd2, https://192.168.124.24:2380, https://192.168.124.24:2379

[root@openshift-master etcd]# etcdctl --cacert=/etc/etcd/etcd-root-ca.pem --cert=/etc/etcd/etcd.pem --key=/etc/etcd/etcd-key.pem --endpoints=https://192.168.124.22:2379,https://192.168.124.23:2379,https://192.168.124.24:2379 endpoint health
https://192.168.124.22:2379 is healthy: successfully committed proposal: took = 3.852481ms
https://192.168.124.23:2379 is healthy: successfully committed proposal: took = 4.035725ms
https://192.168.124.24:2379 is healthy: successfully committed proposal: took = 1.489679ms
```

至此,etcd集群安装完成


## 数据初始化

如果在安装过程中，可能需要重新初始化数据可以参考如下方法

1. 导出API版本，这里使用3版本
```
export ETCDCTL_API=3
```

2. 获取key
```
etcdctl get / --prefix --keys-only
```

3. 删除 openshift.io 相关内容
```
etcdctl del --prefix=true /openshift.io
```

4. 删除 kubernetes.io
```
etcdctl del --prefix=true /kubernetes.io
```

5. 再次查看
```
etcdctl get / --prefix --keys-only
```

