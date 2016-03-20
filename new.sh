#!/bin/bash


# Redhat
# 启动Redhat 7.2 磁盘root分区30G, 数据分区 /data 50G (并自动加载), 分配固定内网ip
./launch_instance.sh ec2_Test_001 ami-52d1183f 30/50 168.161.129.30 t2.micro test testRole subnet_testVPC_App_Cache001 sg_testVPC_App_Cache001

# windows : Dynamic
# 启动Windows2012 磁盘root分区50G(C盘), 动态分配内网ip
./launch_instance.sh ec2_Test_001 ami-cbca01a6 50/0 dynamic t2.micro test testRole subnet_testVPC_App_Cache001 sg_testVPC_App_Cache001
# 启动Windows2012 磁盘root分区50G(C盘), 数据盘 100G（D盘), 分配固定内网ip
./launch_instance.sh ec2_Test_001 ami-cbca01a6 50/0 168.161.129.31 t2.micro test testRole subnet_testVPC_App_Cache001 sg_testVPC_App_Cache001

exit 0
