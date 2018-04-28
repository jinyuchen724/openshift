| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 导入模板和镜像

- 导入镜像
```
[hz01-online-ops-openmasteretc-01 ~]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/image-streams/image-streams-centos7.json -n openshift
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
```

- 导入应用模板
```
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mariadb-ephemeral-template.json -n openshift
template "mariadb-ephemeral" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mariadb-persistent-template.json -n openshift
template "mariadb-persistent" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mongodb-ephemeral-template.json -n openshift
template "mongodb-ephemeral" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mongodb-persistent-template.json -n openshift
template "mongodb-persistent" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mysql-ephemeral-template.json -n openshift
template "mysql-ephemeral" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/mysql-persistent-template.json -n openshift
template "mysql-persistent" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/redis-ephemeral-template.json -n openshift
template "redis-ephemeral" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/db-templates/redis-persistent-template.json -n openshift
template "redis-persistent" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/cakephp-mysql.json -n openshift
template "cakephp-mysql-example" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/cakephp-mysql-persistent.json -n openshift
template "cakephp-mysql-persistent" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/jenkins-ephemeral-template.json -n openshift
template "jenkins-ephemeral" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/jenkins-persistent-template.json -n openshift
template "jenkins-persistent" created
[root@hz01-online-ops-openmasteretc-01 /root]# oc create -f https://github.com/openshift/openshift-ansible/raw/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/httpd.json -n openshift
template "httpd-example" created
```

- 查看导入的镜像列表
```
[root@hz01-online-ops-openmasteretc-01 /root]# oc get is -n openshift
NAME         DOCKER REPO                                TAGS                          UPDATED
httpd        172.30.128.130:5000/openshift/httpd        latest,2.4                    10 minutes ago
jenkins      172.30.128.130:5000/openshift/jenkins      latest,1,2                    10 minutes ago
mariadb      172.30.128.130:5000/openshift/mariadb      latest,10.1                   10 minutes ago
mongodb      172.30.128.130:5000/openshift/mongodb      3.2,2.6,2.4 + 1 more...       10 minutes ago
mysql        172.30.128.130:5000/openshift/mysql        5.5,latest,5.7 + 1 more...    10 minutes ago
nodejs       172.30.128.130:5000/openshift/nodejs       4,6,latest + 1 more...        10 minutes ago
perl         172.30.128.130:5000/openshift/perl         5.24,5.20,5.16 + 1 more...    10 minutes ago
php          172.30.128.130:5000/openshift/php          latest,7.0,5.6 + 1 more...    10 minutes ago
postgresql   172.30.128.130:5000/openshift/postgresql   9.4,9.2,latest + 1 more...    10 minutes ago
python       172.30.128.130:5000/openshift/python       latest,3.5,3.4 + 2 more...    10 minutes ago
redis        172.30.128.130:5000/openshift/redis        latest,3.2                    10 minutes ago
ruby         172.30.128.130:5000/openshift/ruby         latest,2.3,2.2 + 1 more...    10 minutes ago
wildfly      172.30.128.130:5000/openshift/wildfly      8.1,latest,10.1 + 2 more...   10 minutes ag
```

- 查看导入的应用模板列表(相当于企业内部的APPSTORE 应用市场)
```
[root@hz01-online-ops-openmasteretc-01 /root]# oc get templates -n openshift
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