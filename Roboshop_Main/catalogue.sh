#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DIR=$PWD

LOGS_DIR="/var/log/Roboshop"
LOGS_PATH="$LOGS_DIR/$0.log"

if [ $ID -ne 0 ]; then
echo -e "$R This need Root Privilages..Exiting $N" | tee -a $LOGS_PATH
exit 1
else
echo -e "$G Thanks for Running via Root..$N " | tee -a $LOGS_PATH
fi

mkdir -p $LOGS_DIR

VALIDATE(){
    if [ $? -ne 0 ]; then
    echo -e "$R$2 is failure... $N" | tee -a $LOGS_PATH
    else
    echo -e "$G$2 is Success... $N" | tee -a $LOGS_PATH
    fi
}

dnf module disable nodejs -y  &>>$LOGS_PATH
VALIDATE $? "Disable Nodejs"
 
dnf module enable nodejs:20 -y  &>>$LOGS_PATH
VALIDATE $? "enable Nodejs20"

dnf install nodejs -y  &>>$LOGS_PATH
VALIDATE $? "install Nodejs"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi

VALIDATE $? "Roboshop User creation"

mkdir -p /app  &>>$LOGS_PATH
VALIDATE $? "crate /app directory"

rm -rf /app/*

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip ; cd /app ; unzip /tmp/catalogue.zip &>>$LOGS_PATH
VALIDATE $? "Copy and unzip catalogue to /app"

npm install &>>$LOGS_PATH
VALIDATE $? "Dependency install"

cd $DIR
VALIDATE $? "change back to $DIR"

rm -rf /etc/systemd/system/catalogue.service &>>$LOGS_PATH
VALIDATE $? "Remove old catalogue.service"

cp catalogue.service /etc/systemd/system/ &>>$LOGS_PATH
VALIDATE $? "Copy catalogue service"

systemctl daemon-reload &>>$LOGS_PATH
VALIDATE $? "Reload systemd"

systemctl enable --now catalogue  &>>$LOGS_PATH
VALIDATE $? "start and enable catalogue"

rm -rf /etc/yum.repos.d/mongo.repo &>>$LOGS_PATH
VALIDATE $? "Remove mongo repo old"

cp mongo.repo /etc/yum.repos.d/ &>>$LOGS_PATH
VALIDATE $? "Copy new mongo repo"

dnf install mongodb-mongosh -y &>>$LOGS_PATH
VALIDATE $? "install mongodb-mongosh"

mongosh --host mongodb.vsp-97.online </app/db/master-data.js &>>$LOGS_PATH
VALIDATE $? "Copy js"