#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DIR=$PWD

LOG_DIR="/var/log/roboshop"
LOG_Path="$LOG_DIR/$0.log"


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

dnf install maven -y &>>$LOG_Path
VALIDATE $? "Install Maven"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_Path
else
echo " user already Exists"
fi
VALIDATE $? "User Roboshop creation"


mkdir -p /app &>>$LOG_Path
VALIDATE $? "Create /app dir"

rm -rf /app/* &>>$LOG_Path
VALIDATE $? "remove /app/*"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip ; cd /app ; unzip /tmp/shipping.zip &>>$LOG_Path
VALIDATE $? "unzip to /app"

cd /app ; mvn clean package ; mv target/shipping-1.0.jar shipping.jar &>>$LOG_Path
VALIDATE $? " mvn clean package"

cd $DIR

rm -rf /etc/systemd/system/shipping.service &>>$LOG_Path
VALIDATE $? "Remove old shipping service"

cp shipping.service /etc/systemd/system/ &>>$LOG_Path
VALIDATE $? "copy shipping service "


systemctl daemon-reload &>>$LOG_Path
VALIDATE $? "Daemon reload"

systemctl enable --now shipping  &>>$LOG_Path
VALIDATE $? "enable and start"

dnf install mysql -y &>>$LOG_Path
VALIDATE $? "install mysql"

mysql -h mysql.vsp-97.online -uroot -pRoboShop@1 < /app/db/schema.sql
 
mysql -h mysql.vsp-97.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
 
mysql -h mysql.vsp-97.online -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_Path
VALIDATE $? "update schema,app-user,master-data.sql"

systemctl restart shipping &>>$LOG_Path
VALIDATE $? "Restart Shipping"
