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

dnf install golang -y&>>$LOGS_PATH
VALIDATE $? "install golang"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi

mkdir -p /app &>>$LOGS_PATH
VALIDATE $? "mkdir /app"

rm -rf /app/* &>>$LOGS_PATH
VALIDATE $? "rm -rf /app/*"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip ; cd /app ; unzip /tmp/dispatch.zip &>>$LOGS_PATH
VALIDATE $? "unzip dispatch"

cd /app ; go mod init dispatch ; go get ; go build &>>$LOGS_PATH
VALIDATE $? "go build"

rm -rf /etc/systemd/system/dispatch.service &>>$LOGS_PATH
VALIDATE $? "remove old dispatch service"

cd $DIR

cp dispatch.service /etc/systemd/system/ &>>$LOGS_PATH
VALIDATE $? "copy dispatch service"

systemctl daemon-reload &>>$LOGS_PATH
VALIDATE $? "reload daemon"

systemctl enable --now dispatch  &>>$LOGS_PATH
VALIDATE $? "enable and start dispatch"