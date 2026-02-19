#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0acfa65a2eba49cce"

read -p " How many instance you want to deploy: ", Num
echo " this will craete $NUM instance" please 
for instance in $@
do
    echo $instance 

    aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query 'Instances[0].InstanceId' --output text
done
