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

dnf install mysql-server -y &>>$LOGS_PATH
VALIDATE $? "INSTALL MYSQL-SERVER"

systemctl enable --now mysqld &>>$LOGS_PATH
VALIDATE $? "ENABLE AND START MYSQL-SERVER"


mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_PATH
VALIDATE $? "Set Password"