#!/bin/bash

# Ref: http://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/enhanced-networking.html#enhanced_networking_instance_types
# aws ec2 describe-image-attribute --image-id ami-0903c964 --attribute sriovNetSupport

# Functions 
get_instance_status()
{
	aws $PROFILE --region $R ec2 describe-instances --query 'Reservations[*].Instances[*].State.Name' --filter Name=instance-id,Values=$1 --output text
}

stop_instance()
{
	aws $PROFILE --region $R ec2 stop-instances --instance-ids $1
}

start_instance()
{
	aws $PROFILE --region $R ec2 start-instances --instance-ids $1
}

check_yes()
{
	echo -n "$1 [y/n]"
	read A

	if [ "_$A" != "_y" ]; then
		echo "Skip."
		exit 1
	fi
}

# Main
R=cn-north-1

PROFILE=""
if [ "_$1" != "_" ]; then
	PROFILE="--profile $1"
fi

INSTANCE_ID=$2

CMD="aws $PROFILE ec2 describe-instance-attribute --instance-id ${INSTANCE_ID} --attribute sriovNetSupport --output text"

if [ `eval $CMD | grep "SRIOVNETSUPPORT" | grep -c simple` -eq 0 ]; then
	echo "Need to enable SRIOV"

	STATUS=$(get_instance_status ${INSTANCE_ID})

	NEED_ENABLE_SRIOV="no"

	if [ "_$STATUS" = "_running" ]; then
		echo "Instance ${INSTANCE_ID} is running. You should stop it to enable sr-iov"

		check_yes "Stop instance ${INSTANCE_ID} Now? "
		
		stop_instance ${INSTANCE_ID}

		echo -n "Stopping ${INSTANCE_ID}"

		while [ 1 ]; do
			STATUS=$(get_instance_status ${INSTANCE_ID})

			if [ "_$STATUS" = "_stopped" ]; then
				echo -n " Stopped."
				echo
				NEED_ENABLE_SRIOV="yes"
				break
			else
				echo -n "."
			fi	
			
			sleep 1
		done
	else
		echo "Instance ${INSTANCE_ID} is stopped."
		NEED_ENABLE_SRIOV="yes"
	fi
	
	if [ "_${NEED_ENABLE_SRIOV}" = "_yes" ]; then
		echo "Enable ${INSTANCE_ID} --sriov-net-support simple"
		CMD="aws $PROFILE --region $R ec2 modify-instance-attribute --instance-id ${INSTANCE_ID} --sriov-net-support simple"
		eval $CMD

		check_yes "Start instance ${INSTANCE_ID} Now? "
		start_instance ${INSTANCE_ID}
	fi
else
	echo "SRIOV is already enabled"
fi

exit 0

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
