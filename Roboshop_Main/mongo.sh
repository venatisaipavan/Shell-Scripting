#!/bin/bash

ID=$(id -u)

LOG_DIR="/var/log/roboshop/"
LOG_Path="LOG_DIR/$0.log"

if [ $ID -ne 0 ]; then
    echo " Script Need Root Privilages..Exiting!" | tee -a $LOG_Path
    exit 1
    else
 echo "Thanks for running as Root" | tee -a $LOG_Path
fi

VALIDATE() {
   if [ $? -ne 0]; then
    echo "$2... failure" &>>$LOG_Path
    else
    echo "$2... success" &>>$LOG_Path
   fi
}

mkdir -p $LOG_DIR

cp mongo.repo /etc/yum.repos.d/ &>>$LOG_Path
VALIDATE $? "Copy mongo repo"

dnf install mongodb-org -y  &>>$LOG_Path
VALIDATE $? "Mongodb Install"

systemctl enable --now mongod  &>>$LOG_Path
VALIDATE $? "Start and enable mongod"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>$LOG_Path
VALIDATE $? "Replace the Ip in conf"

systemctl restart mongod &>>$LOG_Path
VALIDATE $? "Restart mongod"


