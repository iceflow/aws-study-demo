#!/bin/bash

# Ref: http://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/enhanced-networking.html#enhanced_networking_instance_types


INSTANCE_ID=i-7c550244

aws ec2 modify-instance-attribute --instance-id ${INSTANCE_ID} --sriov-net-support simple

aws ec2 describe-instance-attribute --instance-id ${INSTANCE_ID} --attribute sriovNetSupport

#AMI_ID=ami-5d08c330

#aws ec2 register-image --sriov-net-support simple ${AMI_ID}

# Check 
#modinfo ixgbevf
#lsmod | grep ixgbevf
#
# ethtool -i eth0
driver: ixgbevf
version: 2.12.1-k
firmware-version:
bus-info: 0000:00:03.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no
#
#
aws ec2 describe-instance-attribute --instance-id instance_id --attribute sriovNetSupport
aws ec2 describe-image-attribute --image-id ami-e80fc485 --attribute sriovNetSupport

exit 0
