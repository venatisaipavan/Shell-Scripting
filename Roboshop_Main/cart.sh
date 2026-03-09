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
VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_PATH
VALIDATE $? "Enable Nodejs"

dnf install nodejs -y &>>$LOGS_PATH
VALIDATE $? "Install Nodejs"

id roboshop &>>$LOGS_PATH
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi
VALIDATE $? "Roboshop user creation" 

mkdir -p /app &>>$LOGS_PATH
VALIDATE $? "Create /app dir"

rm -rf /app/*

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip ; cd /app ; unzip /tmp/cart.zip &>>$LOGS_PATH
VALIDATE $? "unzip cart"

cd /app ; npm install &>>$LOGS_PATH
VALIDATE $? "dependency install" 

cd $DIR

cp cart.service /etc/systemd/system/ &>>$LOGS_PATH
VALIDATE $? "Copy Cart"

systemctl daemon-reload &>>$LOGS_PATH
VALIDATE $? "Daemon Reload"

systemctl enable --now cart  &>>$LOGS_PATH
VALIDATE $? "Cart Enable"