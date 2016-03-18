#!/bin/bash

VPC_NAME=BP1
OS=linux
EC2_NAME=$1
AMI_ID=$2
IP=$3
INSTANCE_TYPE=$4
KEY_NAME=$5
ROLE_NAME=$6
SUBNET_NAME=$7
SECURITY_GROUP_NAME=$8

err_quit()
{
	echo "ERR: $1"
	exit 1
}

usage()
{
	echo "Usage:"
	echo "   ./$0 EC2_NAME AMI_ID IP INSTANCE_TYPE KEY_NAME ROLE_NAME SUBNET_NAME SECURITY_GROUP_NAME"
	exit 1
}

get_subnet_id ()
{
	aws ec2 describe-subnets --filters Name=tag:Name,Values=$1 --query 'Subnets[*].[SubnetId]' --output text
}

get_sg_id ()
{
	aws ec2 describe-security-groups  --query 'SecurityGroups[*].[GroupId]' --output text --filters Name=group-name,Values=$1
}

[ $# -ne 8 ] && usage

SUBNET_ID=$(get_subnet_id ${SUBNET_NAME})
SG_ID=$(get_sg_id ${SECURITY_GROUP_NAME})

[ "_$SUBNET_ID" = "_" ] && err_quit "Invalid Subnet Name: ${SUBNET_NAME}"
[ "_$SG_ID" = "_" ] && err_quit "Invalid Security Name: ${SECURITY_GROUP_NAME}"

echo "["$SUBNET_ID"]"
echo "["$SG_ID"]"

#CMD="aws ec2 run-instances --image-id ${AMI_ID} --count 1 --instance-type ${INSTANCE_TYPE} --key-name ${KEY_NAME} --security-group-ids ${SG_ID} --subnet-id ${SUBNET_ID} --private-ip-address ${IP} --iam-instance-profile Name=${ROLE_NAME} --block-device-mappings file://linux-device.json --user-data file://linux-user-data.sh --disable-api-termination"
CMD="aws ec2 run-instances --image-id ${AMI_ID} --count 1 --instance-type ${INSTANCE_TYPE} --key-name ${KEY_NAME} --security-group-ids ${SG_ID} --subnet-id ${SUBNET_ID} --private-ip-address ${IP} --iam-instance-profile Name=${ROLE_NAME} --block-device-mappings file://windows-device.json --disable-api-termination"

INSTANCE_ID=`$CMD | grep InstanceId | cut -d\" -f4`

aws ec2 create-tags --resources ${INSTANCE_ID} --tags Key=Name,Value=${EC2_NAME}

[ $? -ne 0 ] && err_quit "Launch Instance failed: $CMD"

exit 0
