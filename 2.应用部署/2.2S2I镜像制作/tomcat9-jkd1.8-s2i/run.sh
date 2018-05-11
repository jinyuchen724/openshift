#!/bin/sh
appname=$1
env=$2
url=$3
war=$4
http=$5

cd /usr/local/tomcat
rm -rf /usr/local/tomcat/webapps/*

wget $url/$appname/$war 
unzip $war -d /usr/local/tomcat/webapps/ROOT

wget -c -r -nd -k -L -p -nH $url/$appname/disconf/ -P /tmp/disconf
wget -c -r -nd -k -L -p -nH $url/$appname/tomcat/ -P /tmp/tomcat

cp -f /tmp/disconf/* /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/

cp -f /tmp/tomcat/server.xml /usr/local/tomcat/conf/
cp -f /tmp/tomcat/catalina.sh /usr/local/tomcat/bin/

cd /usr/local/tomcat/conf
sed -i 's/<Connector port="[0-9]*"/<Connector port="'$http'"/g' server.xml

exec /usr/local/tomcat/bin/catalina.sh run 

