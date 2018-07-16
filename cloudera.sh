#!/bin/bash
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections &&
sudo add-apt-repository ppa:webupd8team/java -y && sudo apt-get -y update &&
sudo apt-get -y install oracle-java8-installer &&
echo "Installed JAVA Successfully"
sudo mkdir /opt/cloudera
wget https://archive.cloudera.com/cm5/cm/5/cloudera-manager-xenial-cm5.14.1_amd64.tar.gz
sudo gunzip cloudera-manager-xenial-cm5.14.1_amd64.tar.gz
sudo tar -xf cloudera-manager-xenial-cm5.14.1_amd64.tar --directory /opt/cloudera
cat > /etc/apt/sources.list.d/cloudera-manager.list << EOF
# Packages for Cloudera Manager, Version 5, on Ubuntu 16.04 amd64       
deb [arch=amd64] http://archive.cloudera.com/cm5/ubuntu/xenial/amd64/cm xenial-cm5 contrib
deb-src http://archive.cloudera.com/cm5/ubuntu/xenial/amd64/cm xenial-cm5 contrib
EOF
sudo apt-get update
sudo apt-get install  cloudera-manager-server-db-2 << EOF
Y
y

EOF
echo "cloudera manager installed sucessfully"
sudo service cloudera-scm-server-db start
echo "cloudera scm server db started sucessfully"
export LANGUAGE=en_US.UTF-8
sudo apt-get install postgresql-9.5
echo "postgresql installed sucessfully"
sudo service postgresql start
echo "service postgresql started sucessfully"
sudo service postgresql initdb
cd /etc/postgresql/9.5/main/
sed -i 's|shared_buffers = 128MB|shared_buffers = 128MB|g' postgresql.conf
sed -i 's|#wal_buffers = -1|wal_buffers = 8MB|g' postgresql.conf
sed -i 's|#checkpoint_completion_target = 0.5|checkpoint_completion_target = 0.9|g' postgresql.conf
sudo apt-get install -y sysv-rc-conf
echo "sysv rc conf installed sucessfully"
sudo sysv-rc-conf postgresql on
echo "postgresql on sucessfully"
sudo service postgresql restart
echo "postgresql restarted sucessfully"
sudo service postgresql start
#pg_lsclusters
#pg_ctlcluster 9.5 main start
#sudo nano /var/log/postgresql/postgresql-9.5-main.log
#sudo service postgresql restart
sudo -u postgres psql << EOF
CREATE ROLE scm LOGIN PASSWORD 'scm';
CREATE DATABASE scm OWNER scm ENCODING 'UTF8';
EOF
sudo apt-get install -y libmysql-java &&
echo "libmmysql installed sucessfully"
cd /opt/cloudera/cm-5.14.1/share/cmf
sudo ./schema/scm_prepare_database.sh --force  postgresql scm scm scm &&
echo "database prepared sucessfully"
cd /opt/cloudera/cm-5.14.1/etc/init.d/
sudo service cloudera-scm-server start &&
echo "cloudera scm server started sucessfully"
#Install NTP
#sudo apt-get install ntp
#sudo cat > /etc/ntp.config << EOF
#server 0.pool.ntp.org
#server 1.pool.ntp.org
#server 2.pool.ntp.org
#EOF
#chkconfig ntpd on
#service ntpd start
#Disable firewall
sudo ufw disable

#install zookeeper
#sudo apt-get install zookeeper
#sudo apt-get install zookeeper-server
#mkdir -p /var/lib/zookeeper
#chown -R zookeeper /var/lib/zookeeper/
#sudo service zookeeper-server init
#sudo service zookeeper-server start

#sudo hostname myhost-1
