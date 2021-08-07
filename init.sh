#!/bin/bash

# print nice banner

RED='\033[0;31m'
GREEN='\u001b[32;1m'
RESET='\033[0m'
BLINK='\033[33;5m'
echo -e "      ${RED}          ____     _ __       ___      "
echo "               /  _/__  (_) /_     / _ )__ __"
echo "              _/ // _ \/ / __/    / _  / // /"
echo "             /___/_//_/_/\__/    /____/\_, / "
echo "                                       /___/  "
echo;echo;echo;
echo -e "${BLINK}${GREEN}     _ _ ___ _     _   ____          _ _  _    __      "
echo "  __| / | __/ |_ _| |_|__ / __ _ _ _| | || |_ /  \ _ _ "
echo " / _\` | |__ \ | ' \  _||_ \/ _\` | '_|_  _|  _| () | '_|"
echo " \__,_|_|___/_|_||_\__|___/\__, |_|   |_| \__|\__/|_|  "
echo -e "                           |___/                       ${RESET}"               
        
                                                                                                      
#Check for 3 arguments and require them
export machine_name=$1
export ip=$2
export ext=$3
if [ -z $1 ]
  then
    echo "Syntax: ./init {machine_name} {ip} {extension (thm, htb, etc) Default: thm}"
    exit
fi
if [ -z $2 ] 
  then
    echo "Syntax: ./init {machine_name} {ip} {extension (thm, htb, etc) Default: thm}"
    exit
fi
if [ -z $3 ] 
  then
    ext="thm"
fi

echo "Adding /etc/hosts entry"
echo $ip $machine_name.$ext | sudo tee -a /etc/hosts

echo 'Creating folders...'
mkdir -p $machine_name/nmap

cd $machine_name

echo 'Setting up basic files...'
touch creds
touch README.md

echo "# $machine_name" > README.md
echo "## export IP=$ip" >> README.md
echo " " >> README.md
now=$(date)
echo " > Konstantinos Pap - $now" >> README.md
cp /opt/reverse_shells/misc.txt .
cp /opt/reverse_shells/reverse.php .
myip=$(ip addr show | grep tun0 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
echo "Your vpn ip is: $myip"

sed -i "s/{ip}/$myip/" reverse.php
sed -i "s/{ip}/$myip/" misc.txt

echo 'Everything is set up'

echo "Your gobuster syntax is: gobuster dir -x php,html,sh,bin,txt -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://$ip | tee gobuster.log"
echo "Executing gobuster... Results saved at gobuster.log"
xterm -e bash -c "gobuster dir -x php,html,sh,bin,txt -w/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://$ip --wildcard | tee gobuster.log" &

echo "Nikto syntax: nikto --url http://$ip |tee nikto.log"
echo "Executing nikto... Results saved at nikto.log"
xterm -e bash -c "nikto --url http://$ip | tee nikto.log" &
echo;echo;echo
echo "Initializing nmap scan"

echo "Firing up firefox on the website."
firefox http://$machine_name.$ext &

sudo nmap -sS -sV -sC -vvv -oN nmap/initial $ip
subl README.md creds nmap/initial &

echo;echo;echo;echo
echo "Initializing all port scan"

sudo nmap -sS -sV -sC -p- -oN nmap/allports $ip

echo "You can view the complete results of all port scan in nmap/allports"
subl nmap/allports &
