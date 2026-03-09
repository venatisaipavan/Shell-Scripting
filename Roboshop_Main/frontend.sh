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

VALIDATE() {
    if [ $? -ne 0 ]; then
    echo -e "$R$2 is failure... $N" | tee -a $LOGS_PATH
    exit 1
    else
    echo -e "$G$2 is Success... $N" | tee -a $LOGS_PATH
    fi
}

dnf module disable nginx -y &>>$LOGS_PATH
VALIDATE $? "Disable Nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_PATH
VALIDATE $? "enable Nginx"

dnf install nginx -y &>>$LOGS_PATH
VALIDATE $? "Install Nginx"

systemctl enable --now nginx &>>$LOGS_PATH
VALIDATE $? "Enable and start Nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOGS_PATH
VALIDATE $? "Removing old Nginx html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_PATH
VALIDATE $? "Curl frontend"

rm -rf /usr/share/nginx/html/*  &>>$LOGS_PATH

unzip /tmp/frontend.zip -d /usr/share/nginx/html/ &>>$LOGS_PATH
VALIDATE $? "html unzip"

cp nginx.conf /etc/nginx &>>$LOGS_PATH
VALIDATE $? "Copy Nginx Conf"

systemctl restart nginx  &>>$LOGS_PATH
VALIDATE $? "Restart Nginx"