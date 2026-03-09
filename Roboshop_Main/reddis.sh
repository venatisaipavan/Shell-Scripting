#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_DIR="/var/log/roboshop"
LOG_Path="$LOG_DIR/$0.log"

mkdir -p $LOG_DIR

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

dnf module disable redis -y &>> $LOG_Path
VALIDATE $? "disable redis module"

dnf module enable redis:7 -y &>> $LOG_Path
VALIDATE $? "enaable redis module"

dnf install redis -y  &>> $LOG_Path
VALIDATE $? "install redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>> $LOG_Path
VALIDATE $? "Replace Ip in conf"

sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $LOG_Path
VALIDATE $? "Replace protected-mode"

systemctl enable --now redis  &>> $LOG_Path &>> $LOG_Path
VALIDATE $? "enable and start redis"