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

mkdir -p $LOGS_DIR

VALIDATE() {
    if [ $? -ne 0 ]; then
    echo -e "$R$2 is failure... $N" &>>$LOGS_DIR
    else
    echo -e "$G$2 is Success... $N" &>>$LOGS_DIR
}

dnf module disable nginx -y
VALIDATE $? "Disable Nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "enable Nginx"

dnf install nginx -y
VALIDATE $? "Install Nginx"

systemctl enable --now nginx
VALIDATE $? "Enable and start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing old Nginx html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Curl frontend"

unzip /tmp/frontend.zip /usr/share/nginx/html/
VALIDATE $? "html unzip"

cp nginx.conf /etc/nginx
VALIDATE $? "Copy Nginx Conf"

systemctl restart nginx 
VALIDATE $? "Restart Nginx"
