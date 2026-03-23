#!/bin/bash

ip -o link show | grep -v lo | while read -r line; 

do
interface=$(echo $line |  awk -F": " '{print $2}')
done