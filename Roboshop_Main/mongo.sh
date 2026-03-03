#!/bin/bash

ID=$(id -u)

LOG_DIR="/var/log/roboshop/"
LOG_Path="LOG_DIR/$0.log"

if [ $ID -ne 0 ]; then
    echo " Script Need Root Privilages..Exiting!"
    exit 1
    else
 echo "Thanks for running as Root"
fi

VALIDATE() {
   if [ $? -ne 0]; then
    echo "$2... failure"
    else
    echo "$2... success"
   fi
}

mkdir -p $LOG_DIR

cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "Copy mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "Mongodb Install"

systemctl enable --now mongod 
VALIDATE $? "Start and enable mongod"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "Replace the Ip in conf"

systemctl restart mongod
VALIDATE $? "Restart mongod"


