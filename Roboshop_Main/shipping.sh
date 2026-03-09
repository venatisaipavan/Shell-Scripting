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

dnf install maven -y &>>$LOGS_PATH
VALIDATE $? "Install Maven"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_PATH
else
echo " user already Exists"
fi
VALIDATE $? "User Roboshop creation"


mkdir -p /app &>>$LOGS_PATH
VALIDATE $? "Create /app dir"

rm -rf /app/* &>>$LOGS_PATH
VALIDATE $? "remove /app/*"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip ; cd /app ; unzip /tmp/shipping.zip &>>$LOGS_PATH
VALIDATE $? "unzip to /app"

cd /app ; mvn clean package ; mv target/shipping-1.0.jar shipping.jar &>>$LOGS_PATH
VALIDATE $? " mvn clean package"

cd $DIR

rm -rf /etc/systemd/system/shipping.service &>>$LOGS_PATH
VALIDATE $? "Remove old shipping service"

cp shipping.service /etc/systemd/system/ &>>$LOGS_PATH
VALIDATE $? "copy shipping service "


systemctl daemon-reload &>>$LOGS_PATH
VALIDATE $? "Daemon reload"

systemctl enable --now shipping  &>>$LOGS_PATH
VALIDATE $? "enable and start"

dnf install mysql -y &>>$LOGS_PATH
VALIDATE $? "install mysql"

mysql -h mysql.vsp-97.online -uroot -pRoboShop@1 < /app/db/schema.sql
 
mysql -h mysql.vsp-97.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
 
mysql -h mysql.vsp-97.online -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_PATH
VALIDATE $? "update schema,app-user,master-data.sql"

systemctl restart shipping &>>$LOGS_PATH
VALIDATE $? "Restart Shipping"
