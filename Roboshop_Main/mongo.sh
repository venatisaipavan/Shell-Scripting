#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_DIR="/var/log/roboshop/"
LOG_Path="$LOG_DIR/$0.log"

if [ $ID -ne 0 ]; then
    echo "$R Script Need Root Privilages..Exiting! $N" | tee -a $LOG_Path
    exit 1
    else
 echo -e "$G Thanks for running as Root $N " | tee -a $LOG_Path
fi

VALIDATE() {
   if [ $? -ne 0 ]; then
    echo -e "$R$2... failure $N"  | tee -a $LOG_Path
    else
    echo  -e "$G$2... success $N" | tee -a $LOG_Path
   fi
}

mkdir -p $LOG_DIR

rm -rf  /etc/yum.repos.d/mongo.repo
VALIDATE $? "Remove Old mongo repo"

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


