#!/bin/bash

echo " Lets Start the EC2 instances Build"
read -p " How many EC2 instances you required ? " Num

if [[ "$Num" -eq ^[1-9][0-9]*$ ]]; then

echo " Thanks for the details we are going to Build $Num Instances"
else
echo " Details are not accurate Hence exiting..." 
fi
