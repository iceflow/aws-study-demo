#!/bin/bash


#REGION_LIST=`awk '{print $NF}' region_list.conf | xargs`

REGION_LIST="cn-north-1"

PROFILE=$1

[ "_$PROFILE" = "_" ] && PROFILE=default

for R in ${REGION_LIST}; do
	echo "AvailabilityZone,VolumeId,State,Iops,Size,VolumeType"
	aws ec2 --profile $PROFILE describe-volumes --query 'Volumes[].[AvailabilityZone,VolumeId,State,Iops,Size,VolumeType]' --output text | awk '{print $1","$2","$3","$4","$5","$6}'
done
