#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_DIR="/var/log/roboshop"
LOG_Path="$LOG_DIR/$0.log"
DIR=$PWD

mkdir -p $LOG_DIR

if [ $ID -ne 0 ]; then
    echo "$R Script Need Root Privilages..Exiting! $N" | tee -a $LOG_Path
    exit 1
    else
 echo -e "$G Thanks for running as Root $N " | tee -a $LOG_Path
fi

VALIDATE() {
   if [ $? -ne 0 ]; then
    echo -e "$R$2... failure $N"  | tee -a $LOG_Path
    else
    echo  -e "$G$2... success $N" | tee -a $LOG_Path
   fi
}

rm -rf /etc/yum.repos.d/rabbitmq.repo &>> $LOG_Path
VALIDATE $? "Repo Remove Rabbitmq"

cp rabbitmq.repo /etc/yum.repos.d/  &>> $LOG_Path
VALIDATE $? "Repo Copy Rabbitmq"

dnf install rabbitmq-server -y &>> $LOG_Path
VALIDATE $? "Install Rabbitmq"

systemctl enable --now rabbitmq-server &>> $LOG_Path
VALIDATE $? "Enable and start Rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_Path
VALIDATE $? "Add roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_Path
VALIDATE $? "Set Permision"