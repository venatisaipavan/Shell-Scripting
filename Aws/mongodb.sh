#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE() {

    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp C:\devops\Shell_Script_Repo\Shell-Scripting\Aws\mongo.repo /etc/yum.repos.d/ | tee -a $LOGS_FILE
VALIDATE $? "Mongodb Copy"

dnf install mongodb-org -y | tee -a $LOGS_FILE
VALIDATE $? "Install Mongodb"

systemctl enable --now mongod | tee -a $LOGS_FILE
VALIDATE $? "start and enable mongod"

sed -i "/s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf | tee -a $LOGS_FILE
VALIDATE $? "Configure change"

systemctl restart mongod | tee -a $LOGS_FILE
VALIDATE $? "Restart mongod"