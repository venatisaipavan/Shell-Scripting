#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0acfa65a2eba49cce"
Z_ID="Z096594634A83KYO99B9Y"
DOMAIN_NAME="vsp-97.online"

 for i in $@
  do
     INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
    --query 'Instances[*].[InstanceId]' \
    --output text)

    if [ $i == "frontend" ]; then
     IP=$(aws ec2 describe-instances \
     --instance-ids $INSTANCE_ID \
     --query 'Reservations[*].Instances[*].PublicIpAddress' \
     --output text)

      RECORD_NAME="$DOMAIN_NAME" # daws88s.online

    else
     IP=$(aws ec2 describe-instances \
     --instance-ids $INSTANCE_ID \
     --query 'Reservations[*].Instances[*].PrivateIpAddress' \
     --output text)

      RECORD_NAME="$instance.$DOMAIN_NAME" # daws88s.online
    fi

     echo "IP Address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

    echo "record updated for $instance"
  done