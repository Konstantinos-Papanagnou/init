#!/bin/bash

#Check for 2 arguments and require them

if [ -z $1 ]
  then
    echo "Syntax: ./init {machine_name} {ip}"
    exit
fi
if [ -z $2 ] 
  then
    echo "Syntax: ./init {machine_name} {ip}"
    exit
fi


cd ~/Documents

echo 'Creating folders...'
mkdir -p $1/nmap

cd $1

echo 'Setting up basic files...'
touch creds
touch README.md

echo "# $1" > README.md
echo "## export IP=$2" >> README.md
echo " " >> README.md
now=$(date)
echo " > Konstantinos Pap - $now" >> README.md
cp /opt/reverse_shells/misc.txt .
cp /opt/reverse_shells/init/reverse.php .
ip=$(ip addr show | grep tun0 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
echo "Your vpn ip is: $ip"

sed -i "s/{UPDATE}/$ip/" reverse.php
sed -i "s/{ip}/$ip/" misc.txt

echo 'Everything is set up'
echo "Your gobuster syntax is: gobuster dir -x php,html,sh,bin.txt -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://$2 | tee gobuster.log"
echo "Nikto syntax: nikto --url http://$2 |tee nikto.log"
echo;echo;echo
echo "Initializing nmap scan"

sudo nmap -sS -sV -sC -vvv -oN nmap/initial $2
pluma README.md creds nmap/initial &

echo;echo;echo;echo
echo "Initializing all port scan"

sudo nmap -sS -sV -sC -p- -oN nmap/allports $2

echo "You can view the complete results of all port scan in nmap/allports"
pluma nmap/allports &
