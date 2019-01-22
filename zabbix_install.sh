#!/bin/bash


#################################################
#1.拷贝zabbix代理安装包
#2.解压源码包并编译安装
#3.创建zabbix用户和组
#4.拷贝相关IO配置文件
#5.配置zabbix_agentd.conf文件
#6.创建zabbix_agentd.log文件
#7.启动zabbix_agentd并加入到系统启动项
#################################################

filename=zabbix-3.0.9.tar.gz
filedir=zabbix-3.0.9

#################################################
#1.拷贝zabbix代理安装包
#################################################

if [ -f $filename ]; then
	echo "The install file is exist!"
else
	scp root@192.168.27.92:/root/zabbix/$filename .
fi


#################################################
#2.解压源码包并编译安装
#################################################


tar -xzvf $filename
cd $filedir
./configure --enable-agent&&make install


#################################################
#3.创建zabbix用户和组
#################################################

groupadd zabbix
useradd -g zabbix zabbix -s /sbin/nologin

#################################################
#4.拷贝相关IO配置文件
#################################################


mkdir -p /usr/local/sbin/sh/
cd /usr/local/sbin/sh/
scp root@192.168.27.92:/root/zabbix/partition_low_discovery.sh .
chown zabbix:zabbix partition_low_discovery.sh 
chmod 755 partition_low_discovery.sh


#################################################
#5.配置zabbix_agentd.conf文件
#################################################


cd /usr/local/etc/
cat zabbix_agentd.conf |grep -v "#" |grep -v "^$" > zabbix_agentd.conf.bak
cp zabbix_agentd.conf.bak zabbix_agentd.conf
echo "
LogFile=/var/log/zabbix_agentd.log
Server=192.168.27.92
Hostname=$HOSTNAME
UnsafeUserParameters=1
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$4}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$7}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$8}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$11}'
UserParameter=custom.vfs.dev.io.active[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$12}'
UserParameter=custom.vfs.dev.io.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$13}'
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$6}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print \$\$10}'
UserParameter=zabbix_low_discovery[*],/bin/bash /usr/local/sbin/sh/partition_low_discovery.sh \$1" >/usr/local/etc/zabbix_agentd.conf


#################################################
#6.创建zabbix_agentd.log文件
#################################################


touch /var/log/zabbix_agentd.log
chmod 777 /var/log/zabbix_agentd.log
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig


#################################################
#7.启动zabbix_agentd并加入到系统启动项
#################################################


/usr/local/sbin/zabbix_agentd
echo "/usr/local/sbin/zabbix_agentd start" >>/etc/rc.d/rc.local 

#################################################
#END
#################################################
