#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0acfa65a2eba49cce"
PATHS=$(cat /home/cloudshell-user/insname)
read -p " How many instance you want to deploy: " Num

if [ "$Num" -gt 0 ]; then

    echo "This will craete $NUM instance"
    read -p " Please Confirm (yes/no) ": T

         if [ $T == yes ];then
         echo " thanks for confimation"
         for instance in $PATHS
         do
        aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text
         done
elif [ $T == no ];then
echo "you entered as no as requested we cancelled"
else
echo "You are exiting as "
exit 1
fi
else
echo " You didn't provided proper details..Hence exiting"
exit 1
fi
