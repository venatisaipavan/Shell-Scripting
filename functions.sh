#!/bin/bash

USERID=$(id -u)
if [ $USERID !=0 ]; then
    echo " Script execution require root permissions"
    exit 1
fi

VALIDATE() {
    if [ $1 != 0 ];then
    echo $2 installation failed
    exit 1
    else
    echo $2 installation completed
    fi
}

dnf insatll nginx -y

echo "installing nginx"

VALIDATE $? nginx

dnf insatll mysql -y 

echo "installing MYSQL"

VALIDATE $? MYSQL

dnf insatll tomcat -y 

echo "installing tomcat"

VALIDATE $? tomcat
