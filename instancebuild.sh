#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0acfa65a2eba49cce"
PATHS=$(cat /home/cloudshell-user/insname)

read -p "How many servers required to build: " Num

if [ $Num -gt 0 ];then

    read -p " Please Reconfirm to build $Num instances using $AMI_ID (Yes/No)" I
      if [ $I == yes == Yes];then
       echo " Thanks for the confimation, we are going the build the Instances..Please hold"
       :elif [ $I == No == no];then
       echo " Build request will not proceed"
       exit 1
       else
       echo " No confirmation hence exiting..."
       exit 1
      fi
 else
 echo " You provided Number of instances is invalid,Hence Exiting!!"
 exit 1
fi





