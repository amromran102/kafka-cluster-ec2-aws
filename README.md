# Kafka-Cluster-EC2-AWS
Set up multi-broker Kafka cluster on AWS EC2 machines

# Demo
In this Demo we will create a testing environment for kafka multi-broker cluster on 3 EC2 t3a.medium instances using the provided shell scripts, of course for a live environment you should think of a Memory optimized instances as Kafka consumes a huge amout of Memory depending on your needs

# What do you need to follow?
- Create 3 EC2 t3a.medium instances using Amazon Linux 2 AMI and attach an elastic IP for each instance
- Launch the instances in the same VPC with the default security group
Note: You can skip the following step if you are using the default security group
- Allow these ports in security group for zookeeper (2181,2888,3888) and default port 9092 for kafka communications

# Script Explanation
I have attached 3 shell scripts one for each instance, you only need to provide the following in the beginning of each script

broker1="ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com",
broker2="ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com",
broker3="ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com"

After modifying and running the scripts on all the instances, start kafka service by running these commands:
$ sudo systemctl enable broker.service
$ sudo systemctl start broker.service 

The script will do the following for each instance:
 install dependecies,
 download Kafka and extract it,
 setup configuration for zookeeper,
 setup up kafka configuration,
 create zookeeper deamon service,
 create kafka daemon service

Eventually this will allow the communication between the 3 instances and setup kafka multi-broker cluster
 
 # What to do next?
 To check your configuration is working good, ssh into each instance and run the following command to check if a broker is leader or follower $ echo stat | nc localhost 2181 | grep Mode
 
 # Now its time to create a new topic and to produce and consume some messages
 Kindly check "Kafka commands" file attached within this repo
