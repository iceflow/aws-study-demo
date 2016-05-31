#!/bin/bash


#REGION_LIST=`awk '{print $NF}' region_list.conf | xargs`

REGION_LIST="cn-north-1"

PROFILE=$1

for R in ${REGION_LIST}; do
	#if [ "_$PROFILE" != "_" ]; then
	#aws --profile $1 ec2 --region $R describe-volumes --query 'Volumes[].[AvailabilityZone,VolumeId,State,Iops,Size]' --filter Name=status,Values=available --output text
	#else
	#aws ec2 --region $R describe-volumes --query 'Volumes[].[AvailabilityZone,VolumeId,State,Iops,Size]' --filter Name=status,Values=available --output text
	#fi

	echo "AvailabilityZone,VolumeId,State,Iops,Size,VolumeType"
	aws ec2 $PROFILE describe-volumes --query 'Volumes[].[AvailabilityZone,VolumeId,State,Iops,Size,VolumeType]' --output text | awk '{print $1","$2","$3","$4","$5","$6}'
done
