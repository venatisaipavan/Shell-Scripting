#!/bin/bash

##Description: To build Ec2 instances

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0acfa65a2eba49cce"

 count=1
  for instance in $@
  do
   instances=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query Instances[].InstanceId[] --output text)
   echo "instance$count is $instances"
   instanc_[$count]=$instances
   count=$((count+1))
  done

 #for ((i=1; i<=$#; i++))
 #do
 #echo "${instanc_[$i]}"
 #done

echo "${instanc_[1]}"
echo "${instanc_[2]}"
echo "${instanc_[3]}"

