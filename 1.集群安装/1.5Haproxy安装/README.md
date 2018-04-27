+++
title = "Haproxy安装"
date =  2018-03-30T01:46:28-04:00
weight = 5
keywords = "openshift master,架构,docker,部署环境,haproxy"
+++

| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 部署主机说明 

| 主机角色 | IP地址 | 操作系统 | 摘要 | 域名 |
| ---      | -----  | -------- | ---  | ---  |
| 管理节点(Master)  | openshift-master1(192.168.124.22) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + etcd + haproxy | openshift.ops.com |


## 安装haproxy

```
[root@openshift-master1 /root]# yum install haproxy -y
```

- 修改配置文件

```
[root@openshift-master1 /root]# vim /etc/haproxy/haproxy.cfg
# Global settings
#---------------------------------------------------------------------
global
    maxconn     20000
    log         /dev/log local0 info
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
#    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          300s
    timeout server          300s
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 20000

listen stats :9000
    mode http
    stats enable
    stats uri /

frontend  atomic-openshift-api
    bind *:443
    default_backend atomic-openshift-api
    mode tcp
    option tcplog

backend atomic-openshift-api
    balance source
    mode tcp
    server      master0 192.168.124.22:8443 check
    server      master1 192.168.124.23:8443 check
    server      master2 192.168.124.24:8443 check
```

**注意: 确保域名 openshift.ops.com 指向Haproxy (如没配置dns,请在各计算节点做hosts绑定)**

## 启动服务

```
systemctl enable haproxy
systemctl start haproxy
```
