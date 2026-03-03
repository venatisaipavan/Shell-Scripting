#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

read -p "Please provide Mongodb Ip address: " Mongodb_IP

dnf module disable nodejs -y &>>$LOGS_FILE 
VALIDATE $? "Nodejs disable"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Nodejs enable"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Nodejs install"

id roboshop

if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
VALIDATE $? "roboshop User Creation"
else
 echo "user exist ..skipping"

mkdir -p /app 

rm -rf /app/*

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip; cd /app ; unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "unzip catalogue"

cd /app ; npm install &>>$LOGS_FILE
VALIDATE $? "npm dependency"

cd ~-

cp catalogue.service /etc/systemd/system/ &>>$LOGS_FILE
VALIDATE $? "catalogue copy"

sed -i "s/<MONGODB-SERVER-IPADDRESS>/${Mongodb_IP}/g" /etc/systemd/system/catalogue.service &>>$LOGS_FILE
VALIDATE $? "Mongo ip updated in /etc/systemd/system/catalogue.service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "daemon reload"

systemctl enable --now catalogue &>>$LOGS_FILE
VALIDATE $? "start and enable catralogue"

cp mongo.repo /etc/yum.repos.d/ &>>$LOGS_FILE
VALIDATE $? "Mongodb repo Copy"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Install Mongodb-mongosh"

mongosh --host ${Mongodb_IP} </app/db/master-data.js &>>$LOGS_FILE

output=$(mongosh --host ${Mongodb_IP}) &>>$LOGS_FILE
echo "$output"
