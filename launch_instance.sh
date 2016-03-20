#!/bin/bash

CONFIG_FILE=config

VPC_NAME=BP1
OS=linux
EC2_NAME=$1
AMI_ID=$2
DISK=$3
IP=$4
INSTANCE_TYPE=$5
KEY_NAME=$6
ROLE_NAME=$7
SUBNET_NAME=$8
SECURITY_GROUP_NAME=$9

LOG_DIR=logs/
LOG_FILE=${LOG_DIR}/launch.log

do_log()
{
	echo "`date +"%Y/%m/%d %T"`: $1" >> ${LOG_FILE}
}

err_quit()
{
	
	MSG="ERR: $1"

	do_log "$MSG"

	echo $MSG
	exit 1
}

usage()
{
	echo "Usage:"
	echo "   $0 EC2_NAME AMI_ID DISK IP|dynamic INSTANCE_TYPE KEY_NAME ROLE_NAME SUBNET_NAME SECURITY_GROUP_NAME"
	exit 1
}

get_vpc_id()
{
	aws ec2 describe-vpcs --query Vpcs[].VpcId --filters Name=tag-key,Values=Name Name=tag-value,Values=$1 --output text
}

get_subnet_id ()
{
	aws ec2 describe-subnets --filters Name=tag:Name,Values=$1 --query 'Subnets[*].[SubnetId]' --output text
}

get_sg_id ()
{
	aws ec2 describe-security-groups  --query 'SecurityGroups[*].[GroupId]' --output text --filters Name=group-name,Values=$1
}

role_exists()
{
	eval aws iam list-roles --query Roles[].[RoleName] --output text |grep -c "^$1$"
}

key_pair_exists()
{
	eval aws ec2 describe-key-pairs --query KeyPairs[].[KeyName] --filters Name=key-name,Values=$1 --output text | grep -c "^$1$"
}


guess_platform()
{
	aws ec2 describe-images --query Images[].[Platform] --filters Name=image-id,Values=$1 --output text
}

make_block_mapping_file()
{
	# TODO: Support only up to two devices this time, DISK allocation format:  root_disk_size/data_disk_size 

	AMI_ID=$1
	ROOT_DISK_SIZE=$(echo $2|cut -d/ -f1)
	DATA_DISK_SIZE=$(echo $2|cut -d/ -f2)

	DIR=block_device_map

	[ -d $DIR ] || mkdir -p $DIR

	ROOT_SNAPSHOT_ID=$(aws ec2 describe-images --query Images[].BlockDeviceMappings[0].[Ebs.SnapshotId] --filters Name=image-id,Values=${AMI_ID} --output text)

	[ "_${ROOT_SNAPSHOT_ID}" = "_" ] && err_quit "Empty root snapshot id for image ${AMI_ID}"

	DST="$DIR/${ROOT_DISK_SIZE}-${DATA_DISK_SIZE}.json"

	## TODO
echo "[
  {
    \"DeviceName\": \"/dev/sda1\",
    \"Ebs\": {
      \"DeleteOnTermination\": true,
      \"SnapshotId\": \"${ROOT_SNAPSHOT_ID}\",
      \"VolumeSize\": ${ROOT_DISK_SIZE},
      \"VolumeType\": \"gp2\"
        }
  } " > $DST

	if [ ${DATA_DISK_SIZE} -gt 0 ]; then
echo "  ,{
    \"DeviceName\": \"/dev/sdb\",
    \"Ebs\": {
      \"DeleteOnTermination\": true,
      \"VolumeSize\": ${DATA_DISK_SIZE},
      \"VolumeType\": \"gp2\",
      \"Encrypted\": false
    }
  } " >> $DST
	fi

echo "] "  >> $DST

	echo $DST
}

### Main ###
[ -d ${LOG_DIR} ] || mkdir -p ${LOG_DIR}
[ -f ${CONFIG_FILE} ] || err_quit "Missing configuration file: ${CONFIG_FILE}"
. ${CONFIG_FILE}

[ $# -ne 9 ] && usage

VPC_NAME=${DEFAULT_VPC_NAME}

VPC_ID=$(get_vpc_id ${VPC_NAME})
SUBNET_ID=$(get_subnet_id ${SUBNET_NAME})
SG_ID=$(get_sg_id ${SECURITY_GROUP_NAME})
PLATFORM=$(guess_platform ${AMI_ID})
# Making block device mapping file
DEVICE_MAPPING_FILE=$(make_block_mapping_file ${AMI_ID} $DISK)

[ "_${SUBNET_ID}" = "_" ] && err_quit "Invalid Subnet Name: ${SUBNET_NAME}"
[ "_${SG_ID}" = "_" ] && err_quit "Invalid Security Name: ${SECURITY_GROUP_NAME}"
[ `role_exists ${ROLE_NAME}` -eq 0  ] && err_quit "Invalid Role Name: ${ROLE_NAME}"
[ `key_pair_exists ${KEY_NAME}` -eq 0  ] && err_quit "Invalid Key Name: ${KEY_NAME}"
[ "_${DEVICE_MAPPING_FILE}" = "_" ] && err_quit "Invalid device mapping file: ${DEVICE_MAPPING_FILE}"

echo "vpc_id[${VPC_NAME}/${VPC_ID}] subnet_id[${SUBNET_NAME}/${SUBNET_ID}] security_group_id[${SECURITY_GROUP_NAME}/${SG_ID}] PLATFORM[$PLATFORM]"


CMD="aws ec2 run-instances --image-id ${AMI_ID} --count 1 --instance-type ${INSTANCE_TYPE} --key-name ${KEY_NAME} --security-group-ids ${SG_ID} --subnet-id ${SUBNET_ID} --iam-instance-profile Name=${ROLE_NAME} --block-device-mappings file://${DEVICE_MAPPING_FILE} --disable-api-termination"

if [ "_${IP}" != "_" -a "_${IP}" != "_dynamic" ]; then
	CMD="$CMD --private-ip-address ${IP}"
fi

if [ "_${PLATFORM}" != "_windows"  ]; then
	CMD="$CMD --user-data file://${DEFAULT_LINUX_USER_DATA}"
fi

INSTANCE_ID=`$CMD | grep InstanceId | cut -d\" -f4`

aws ec2 create-tags --resources ${INSTANCE_ID} --tags Key=Name,Value=${EC2_NAME}

[ $? -ne 0 ] && err_quit "Launch Instance failed: $CMD"

echo "... Launching ${INSTANCE_ID}"

do_log "Launching ${INSTANCE_ID}: $CMD"

exit 0
