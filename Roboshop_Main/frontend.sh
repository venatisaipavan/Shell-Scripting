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
echo -e "$R This need Root Privilages..Exiting $N" | tee -a $LOGS_DIR
exit 1
else
echo -e "$G Thanks for Running via Root..$N " | tee -a $LOGS_DIR
fi

mkdir -p $LOGS_DIR

VALIDATE() {
    if [ $? -ne 0 ]; then
    echo -e "$R$2 is failure... $N" | tee -a $LOGS_DIR
    exit 1
    else
    echo -e "$G$2 is Success... $N" | tee -a $LOGS_DIR
    fi
}

dnf module disable nginx -y &>>$LOGS_DIR
VALIDATE $? "Disable Nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_DIR
VALIDATE $? "enable Nginx"

dnf install nginx -y &>>$LOGS_DIR
VALIDATE $? "Install Nginx"

systemctl enable --now nginx &>>$LOGS_DIR
VALIDATE $? "Enable and start Nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOGS_DIR
VALIDATE $? "Removing old Nginx html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_DIR
VALIDATE $? "Curl frontend"

unzip /tmp/frontend.zip /usr/share/nginx/html/ &>>$LOGS_DIR
VALIDATE $? "html unzip"

cp nginx.conf /etc/nginx &>>$LOGS_DIR
VALIDATE $? "Copy Nginx Conf"

systemctl restart nginx  &>>$LOGS_DIR
VALIDATE $? "Restart Nginx"