#!/bin/bash

if [ $USERID !=0 ];then
    echo "Script Required Root privilage to Run"
    exit 1 
fi
 
Log_Folder="/var/log/shell-script"
Log_file="/var/log/shell-script/$0.log"

Validate(){
    if [ $0 != 0 ];then
        echo "$1 is failure"
       else
        echo "$1 is success"
    fi
}

echo "$@ installing"

dnf install $@

validate $? "$@"