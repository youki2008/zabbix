#! /bin/bash

### 判断当前用户是否为管理员用户 ###
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1


### 查看当前系统版本并安装对应版本软件包  ###
echo "########## begin insatll zabbix_agent #########"
sleep 1
VER=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`

if [ $VER -eq 5 ] ; then
   cd ./RHEL5/64bit&&rpm -ivh zabbix-3.0.9-1.el5.src.rpm&&rpm -ivh zabbix-agent-3.0.9-1.el5.x86_64.rpm&&rpm -ivh zabbix-sender-3.0.9-1.el5.x86_64.rpm
fi

if [ $VER -eq 6 ] ; then
   cd ./RHEL6&&rpm -ivh zabbix-3.0.9-1.el6.src.rpm&&rpm -ivh zabbix-agent-3.0.9-1.el6.x86_64.rpm&& rpm -ivh zabbix-sender-3.0.9-1.el6.x86_64.rpm

fi

if [ $VER -eq 7 ] ; then
    cd ./RHEL7&&rpm -ivh zabbix-3.0.9-1.el7.src.rpm&&rpm -ivh zabbix-agent-3.0.9-1.el7.x86_64.rpm&&rpm -ivh zabbix-sender-3.0.9-1.el7.x86_64.rpm

fi

echo "########## end insatll zabbix_agent #########"

sleep 1

###  modify zabbix_agentd.conf  ###
echo "##########begin modify zabbix_agentd.conf##########"
sed -i 's/^Server=127.0.0.1/Server=192.168.27.92/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=127.0.0.1/ServerActive=192.168.27.92/g' /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf
sed -i '/Timeout=3$/a\Timeout=30' /etc/zabbix/zabbix_agentd.conf
#grep -v '^#' /etc/zabbix/zabbix_agentd.conf |grep -v '^$'
echo "##########end modify zabbix_agentd.conf##########"
sleep 1

echo "#########start zabbix-agent service#########"
### start zabbix-agent service ###
if [ $VER -eq 5 ] ; then
  service zabbix-agent start&&chkconfig zabbix-agent on
fi

if [ $VER -eq 6 ] ; then
  service zabbix-agent start&&chkconfig zabbix-agent on
fi

if [ $VER -eq 7 ]; then
  systemctl start zabbix-agent&&systemctl enable zabbix-agent
fi  

sleep 1
echo "#########install zabbix agent success!!!#########"
