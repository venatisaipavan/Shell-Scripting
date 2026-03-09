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

dnf module disable nodejs -y
VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enable Nodejs"

dnf install nodejs -y
VALIDATE $? "Install Nodejs"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi
VALIDATE $? "Roboshop user creation"

mkdir -p /app 
VALIDATE $? "Create /app dir"

rm -rf /app/*

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip ; cd /app ; unzip /tmp/cart.zip
VALIDATE $? "unzip cart"

cd /app ; npm install
VALIDATE $? "dependency install" 

cd $DIR

cp cart.service /etc/systemd/system/
VALIDATE $? "Copy Cart"

systemctl daemon-reload
VALIDATE $? "Daemon Reload"

systemctl enable --now cart 
VALIDATE $? "Cart Enable"