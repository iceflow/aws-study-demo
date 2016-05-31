#!/bin/bash


REGION_LIST="cn-north-1"


#PROFILE=$1

for R in ${REGION_LIST}; do
        #if [ "_$PROFILE" != "_" ]; then
        #else
        #        aws ec2 --region $R describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId, InstanceType]' --filter Name=instance-state-code,Values=16 --output text 
        #fi
		echo "AvailabilityZone,State,InstanceId,InstanceType,Name"
		aws $PROFILE ec2 --region $R describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId, InstanceType, Tags[0].Value]' --filter Name=instance-state-code,Values=16,80 --output text | awk '{print $1","$2","$3","$4","$5}'
done
