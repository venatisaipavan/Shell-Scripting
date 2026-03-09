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


dnf install python3 gcc python3-devel -y &>> $LOG_Path
VALIDATE $? "Python installation"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi

mkdir -p /app &>> $LOG_Path
VALIDATE $? "mkdir /app"

rm -rf /app/*
VALIDATE $? " rm -rf /app/*"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip ; cd /app ; unzip /tmp/payment.zip &>> $LOG_Path
VALIDATE $? "unzip payment"

cd /app ; pip3 install -r requirements.txt &>> $LOG_Path
VALIDATE $? "Requirement.txt "

rm -rf /etc/systemd/system/payment.service &>> $LOG_Path
VALIDATE $? "Remove old Payment service "

cd $DIR

cp payment.service /etc/systemd/system/ &>> $LOG_Path
VALIDATE $? "CopyPayment service"

systemctl daemon-reload &>> $LOG_Path
VALIDATE $? "Daemon Reload"

systemctl enable --now payment  &>> $LOG_Path
VALIDATE $? "Payment enable and start