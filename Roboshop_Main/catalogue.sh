#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DIR=$PWD

LOGS_DIR="/var/log/Roboshop/"
LOGS_PATH="$LOGS_DIR/$0.log"

if [ $ID -ne 0 ]; then
echo "$R This need Root Privilages..Exiting $N" | tee -a $LOGS_DIR
exit 1
else
echo "$G Thanks for Running via Root..$N " | tee -a $LOGS_DIR

mkdir -p $LOGS_DIR

VALIDATE(){
    if [ $? -ne 0 ]; then
    echo "$R$2 is failure... $N" &>>$LOGS_DIR
    else
    echo "$G$2 is Success... $N" &>>$LOGS_DIR
}

dnf module disable nodejs -y  &>>$LOGS_DIR
VALIDATE $? "Disable Nodejs"
 
dnf module enable nodejs:20 -y  &>>$LOGS_DIR
VALIDATE $? "enable Nodejs20"

dnf install nodejs -y  &>>$LOGS_DIR
VALIDATE $? "install Nodejs"
 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_DIR
VALIDATE $? "Roboshop User creation"

mkdir -p /app  &>>$LOGS_DIR
VALIDATE $? "crate /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip ; cd /app ; unzip /tmp/catalogue.zip &>>$LOGS_DIR
VALIDATE $? "Copy and unzip catalogue to /app"

npm install &>>$LOGS_DIR
VALIDATE $? "Dependency install"

cd $DIR
VALIDATE $? "change back to $DIR"

rm -rf /etc/systemd/system/catalogue.service &>>$LOGS_DIR
VALIDATE $? "Remove old catalogue.service"

cp catalogue.service /etc/systemd/system/ &>>$LOGS_DIR
VALIDATE $? "Copy catalogue service"

systemctl daemon-reload &>>$LOGS_DIR
VALIDATE $? "Reload systemd"

systemctl enable --now catalogue  &>>$LOGS_DIR
VALIDATE $? "start and enable catalogue"

rm -rf /etc/yum.repos.d/mongo.repo &>>$LOGS_DIR
VALIDATE $? "Remove mongo repo old"

cp mongo.repo /etc/yum.repos.d/ &>>$LOGS_DIR
VALIDATE $? "Copy new mongo repo"

dnf install mongodb-mongosh -y &>>$LOGS_DIR
VALIDATE $? "install mongodb-mongosh"

mongosh --host mongodb.vsp-97.online </app/db/master-data.js &>>$LOGS_DIR
VALIDATE $? "Copy js"