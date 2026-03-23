#!/bin/bash


R="\e[31m""\e[5m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "$Y Hostname     - $G $HOSTNAME"
echo -e "$Y uptime       - $G $(uptime -p | sed 's/up //') $N "
echo -e "$Y date & Time  - $G $(date)$N"
echo -e "$Y Timezone     - $G $(timedatectl show -p Timezone | cut -d= -f2)$N"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "$Y OS Version      $N : $G $NAME $VERSION $N"
else
    echo "Cannot detect OS version (no /etc/os-release found)"
fi

echo -e "$Y Disk Usage $N "
echo -e "$G $(df -hT | grep -v tmpfs) $N"

echo -e "$Y Total Mounted filesystems - $G $(df -hT | grep -v tmpfs | tail -n +2 | wc -l) $N"

ip -o link show | grep -v lo | while read -r line;
do
interface=$(echo $line |  awk -F": " '{print $2}')
link=$(echo $line | grep -oP 'state \K\S+')
IP=$(ip -o -4 addr show "$interface" | awk '{print $4}')
echo -e "$Y Network Interfaces: $G $interface - $link - $IP $N"
done

echo -e "$Y DNS Configuration (/etc/resolv.conf) $N"
echo -e "$G $(cat /etc/resolv.conf | grep -i nameserver) $N"

echo -e "$Y Security Processes: $N"

process=("tanium" "s1" "managesoft" "rapid7" "tomcat" "nginx" "dsmc" "oneagent")

for i in "${process[@]}"
do
    pid=$(pgrep -f "$i")

    if [ -n "$pid" ]
    then
        echo -e "$G$i Process is running (PID: $pid) $N"
    else
        echo -e "$R$i Process is not running $N"
    fi
done

echo -e "$Y Security  Services: $N"

services=("nginx" "tomcat" "dsmc" "oneagent")
for i in "${services[@]}"
do
    state=$(systemctl is-active $i 2>/dev/null )
    if [ $? -eq 0 ]; then
       echo -e " $G$i Service is $state and running $N"
    else
       echo -e " $R$i Service is $state and not running $N"
    fi
done

echo -e "$Y Mount Points Check : $N"

mount -a > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo -e "$R Mount check FAILED.$N"
else
        echo -e "$G All filesystems mounted successfully. $N"
fi

echo -e "$Y Memory Usage $N"
echo -e "$(free -h)"

echo -e "$Y CPU Load $N"
echo -e " $(uptime | awk -F'load average:' '{print $2}') "

