#!/bin/bash
h=$HOSTNAME
d=$(date +%d_%m_%y)

mkdir -p /root/"$h"_patching_checks_"$d"
logfile=/root/"$h"_patching_checks_"$d"/precheck.txt

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

{
echo -e "$Y Hostname     - $G $h"
echo -e "$Y uptime       - $G $(uptime -p | sed 's/up //') $N "
echo -e "$Y date & Time  - $G $(date)$N"
echo -e "$Y Timezone     - $G $(timedatectl show -p Timezone | cut -d= -f2)$N"

if [ -f /etc/os-release ]; then
    . /etc/os-release
echo -e "$Y OS Version   - $G $NAME $VERSION $N"
else
    echo "Cannot detect OS version (no /etc/os-release found)"
fi

echo " "
echo -e "$Y Mount Points Check : $N"

mount -a > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo -e "$R Mount check FAILED.$N"
else
        echo -e "$G All filesystems mounted successfully. $N"
fi

echo " "
echo -e "$Y Disk Usage $N "
echo -e "$G $(df -hT | grep -v tmpfs) $N"

echo " "
echo -e "$Y Total Mounted filesystems - $G $(df -hT | grep -v tmpfs | tail -n +2 | wc -l) $N"

echo " "
ip -o link show | grep -v lo | while read -r line;
do
interface=$(echo $line |  awk -F": " '{print $2}')
link=$(echo $line | grep -oP 'state \K\S+')
IP=$(ip -o -4 addr show "$interface" | awk '{print $4}')
echo -e "$Y Network Interfaces: $G $interface - $link - $IP $N"
done

echo " "
echo -e "$Y DNS Configuration (/etc/resolv.conf) $N"
echo -e "$G $(cat /etc/resolv.conf | grep -v "^#") $N"

echo " "
echo -e "$Y Security Processes: $N"

process=("Tanium" "s1" "managesoft" "rapid7" "dsmc" "oneagent" "lwsmd")

for i in "${process[@]}"
do
    pid=$(pgrep -f "$i")
    if [ -n "$pid" ]
    then
        printf " ${G}%-12s Process is running${N}\n" "$i"
    else
        printf " ${R}%-12s Process is not running${N}\n" "$i"
    fi

done
echo " "

echo -e "$Y Security  Services: $N"

services=("taniumclient" "sentinelone" "oneagent" "dsmcad" "ir_agent" "mgsusageag" "ndtask" "lwsmd" "sysstat-collect.timer" "rsyslog" "logrotate.timer")
for i in "${services[@]}"
do
    state=$(systemctl is-active $i 2>/dev/null )
    if [ "$state" = "active" ]; then
        printf " ${G}%-22s Service is %-8sand running${N}\n" "$i" "$state"
    else
        printf " ${R}%-22s Service is %-8sand not running${N}\n" "$i" "$state"
    fi
done

echo " "
echo -e "$Y Memory usage :"
echo -e "$G"
free -h
echo -e "$N"

echo " "
echo -e "$Y CPU Load : $G $(uptime | awk -F'load average:' '{print $2}') $N"

} > $logfile


{
        date; cat /etc/*release; df -hTP; ps -ef; ip a; cat /etc/resolv.conf; lsblk; cat /etc/fstab; cat /etc/hosts; mount; lsmod;  ls -ltr /; rpm -qa; ip route show; ss -antlp; uname -r

} >> $logfile"_os_fs_nw_details.txt"
systemctl list-unit-files >> $logfile"_ServiceList"