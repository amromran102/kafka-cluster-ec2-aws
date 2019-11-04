#!/bin/bash

## setup variables
home="/home/ec2-user"
kafkahome="/home/ec2-user/kafka"
broker1="ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com"
broker2="ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com"
broker3="ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com"

## dependecies
sudo yum update -y
sudo yum install java-1.8.0-openjdk -y
sudo yum install java-1.8.0-openjdk-devel -y

## download kafka
wget https://www-eu.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz $home
tar -xzvf $home/kafka_2.12-2.2.1.tgz && sudo mv $home/kafka_2.12-2.2.1 $home/kafka
rm $home/kafka_2.12-2.2.1.tgz

## setup configuration for zookeeper
sudo mkdir /var/lib/zookeeper/ 
sudo touch /var/lib/zookeeper/myid 
echo "1" | sudo tee /var/lib/zookeeper/myid
sudo cp $kafkahome/config/zookeeper.properties $kafkahome/config/zookeeper.properties.orig
sudo cat > $kafkahome/config/zookeeper.properties <<EOF
dataDir=/var/lib/zookeeper
clientPort=2181
maxClientCnxns=0
initLimit=5
syncLimit=2
tickTime=2000
# list of servers, REPLACE with your public DNS
server.1=0.0.0.0:2888:3888
server.2=$broker2:2888:3888
server.3=$broker3:2888:3888
EOF

## set up kafka configuration
sudo cp $kafkahome/config/server.properties $kafkahome/config/server.properties.orig
sudo sed -i 's/broker.id=0/broker.id=10/g' $kafkahome/config/server.properties
sudo sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$broker1:2181,$broker2:2181,$broker3:2181/g" $kafkahome/config/server.properties
sudo cat >> $kafkahome/config/server.properties <<EOF


####
##
advertised.host.name=$broker1
## Delete Topic
delete.topic.enable=true
####
EOF

## create zookeeper deamon service
sudo cat > /etc/systemd/system/zoo.service <<EOF
[Unit]
Description=Zookeeper 1 Daemon
Wants=syslog.target

[Service]
Type=simple
WorkingDirectory=$kafkahome
User=root
ExecStart=$kafkahome/bin/zookeeper-server-start.sh $kafkahome/config/zookeeper.properties
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

## start zookeeper service
sudo systemctl enable zoo.service
sudo systemctl start zoo.service

## create kafka daemon service
sudo cat > /etc/systemd/system/broker.service <<EOF
[Unit]
Description=Broker 10 Daemon
Wants=syslog.target

[Service]
Type=simple
WorkingDirectory=$kafkahome
User=root
ExecStart=$kafkahome/bin/kafka-server-start.sh $kafkahome/config/server.properties
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
