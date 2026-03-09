#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DIR=$PWD

LOGS_DIR="/var/log/Roboshop"
LOGS_PATH="$LOGS_DIR/$0.log"

mkdir -p $LOGS_DIR

if [ $ID -ne 0 ]; then
echo -e "$R This need Root Privilages..Exiting $N" | tee -a $LOGS_PATH
exit 1
else
echo -e "$G Thanks for Running via Root..$N " | tee -a $LOGS_PATH
fi



VALIDATE(){
    if [ $? -ne 0 ]; then
    echo -e "$R$2 is failure... $N" | tee -a $LOGS_PATH
    else
    echo -e "$G$2 is Success... $N" | tee -a $LOGS_PATH
    fi
}

dnf module disable nodejs -y &>>$LOGS_PATH
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_PATH
VALIDATE $? "enable nodejs"

dnf install nodejs -y &>>$LOGS_PATH
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi
VALIDATE $? "User Roboshop creation"

mkdir -p /app  &>>$LOGS_PATH

rm -rf /app/*

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip; cd /app; unzip /tmp/user.zip  &>>$LOGS_PATH
VALIDATE $? "unzip user"

cd /app ; npm install &>>$LOGS_PATH
VALIDATE $? "dependency check"

cd $DIR

cp user.service /etc/systemd/system/ &>>$LOGS_PATH
VALIDATE $? "copy user service "

systemctl daemon-reload &>>$LOGS_PATH
VALIDATE $? "reload systemd"

systemctl enable --now user &>>$LOGS_PATH
VALIDATE $? "restart user service"


