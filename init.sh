#!/bin/bash

# print nice banner

RED='\033[0;31m'
YELLOW='\e[93m'
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
    echo -e "${RED}[-] Syntax: ./init {machine_name} {ip} {extension (thm, htb, etc) Default: thm}${RESET}"
    exit
fi
if [ -z $2 ] 
  then
    echo -e "${RED}[-] Syntax: ./init {machine_name} {ip} {extension (thm, htb, etc) Default: thm}${RESET}"
    exit
fi
if [ -z $3 ] 
  then
    ext="thm"
fi

if [ ! -d /opt/init ]; then
  echo -e "${RED}[-] Could not find base init directory. Please install the script first...${RESET}"
  exit
fi
if [ ! -d /opt/init/reverse_shells ]; then
  echo -e "${RED}[-] Could not find base init/reverse_shells directory. Please install the script first...${RESET}"
  exit
fi
if [ ! -f /opt/init/reverse_shells/misc.txt ]; then
  echo -e "${RED}[-] Could not find misc.txt. Please install the script first...${RESET}"
  exit
fi
if [ ! -f /opt/init/reverse_shells/reverse.php ]; then
  echo -e "${RED}[-] Could not find reverse.php. Please install the script first...${RESET}"
  exit
fi
if [ ! -f /opt/init/anonymouschecker.sh ]; then 
  echo -e "${RED}[-] Could not find anonymouschecker.sh. Please install the script first...${RESET}"
  exit
fi

echo -e "${GREEN}[+] Adding /etc/hosts entry${RESET}"
echo $ip $machine_name.$ext | sudo tee -a /etc/hosts

echo -e "${GREEN}[+] Creating folders...${RESET}"
if [ ! -d $machine_name ]; then
  mkdir $machine_name
fi
cd $machine_name
if [ ! -d nmap ]; then
  mkdir nmap
fi
if [ ! -d ftp ]; then
  mkdir ftp
fi
if [ ! -d web ]; then
  mkdir web
fi

echo -e "${GREEN}[+] Setting up basic files...${RESET}"
if [ ! -f creds ]; then
  touch creds
fi
if [ ! -f README.md ]; then

  touch README.md

  echo "# $machine_name" > README.md
  echo "## export IP=$ip" >> README.md
  echo " " >> README.md
  now=$(date)
  echo " > Konstantinos Pap - $now" >> README.md
fi

cp /opt/init/reverse_shells/misc.txt .
cp /opt/init/reverse_shells/reverse.php .
cp /opt/init/anonymouschecker.sh .
chmod +x anonymouschecker.sh
myip=$(ip addr show | grep tun0 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
echo -e "${GREEN}[*] Your vpn ip is: $myip ${RESET}"

sed -i "s/{ip}/$myip/" reverse.php
sed -i "s/{ip}/$myip/" misc.txt
sed -i "s/{ip}/$ip/" anonymouschecker.sh

echo -e "${GREEN}[*] Everything is set up"
echo;
echo -e "       ¡Vamos!${RESET}" 
echo;echo;

echo -e "${YELLOW}[*] Checking Remote System Health...${RESET}"
if [ `ping $ip -c 1 | grep 64 -c` -gt 0 ];then
  echo -e "${GREEN}[+] Remote System Alive...${RESET}"
  pn=""
else
  echo -e "${RED} [-] Remote System Does Not Respond To Pings (Most Likely a Windows Machine)... Treating Host As Alive..${RESET}"
  pn="-Pn"
fi

echo -e "${YELLOW}[*] Finding alive ports using nmap...${RESET}"
nohup nmap $pn -v -p- -T4 $machine_name.$ext | tee nmap/ports 1>/dev/null & 
sudo nohup nmap $pn -O $ip | tee nmap/os.detection 1>/dev/null &
osdone=0
portscandone=0
knownports=()
while [ 1 ]; do
  if [ $portscandone = 0 ]; then
    if [ -f nmap/ports ]; then
      if [ `cat nmap/ports | grep "Nmap done:" -c` -gt 0 ]; then
        portscandone=1
      fi
      ports=`cat nmap/ports | grep open | cut -d "/" -f1 | cut -d ' ' -f4 2>/dev/null`
      for port in $ports; do
        if [[ " ${knownports[*]} " =~ " ${port} " ]]; then
          continue;
        fi
        knownports+=($port)
        echo -e "${GREEN}[+] Found Open Port: $port${RESET}"
        if [ $port -eq 21 ]; then
          echo -e "${YELLOW}[+] Detected FTP Service."
          echo -e "[*] Fingerprinting Version.. " ;
          service=`timeout 1 nc $ip $port` 
          echo $service | cut -d ' ' -f2,3
          echo -e "[*] Attempting to anonymously login...${RESET}"
          nohup ./anonymouschecker.sh > ftp/ftp.log
          res=`cat ftp/ftp.log | grep "Login successful" -c`
          if [ $res -gt 0 ]; then
            echo -e "${GREEN}[*] Anonymous Login Successful. Files Retrieved:"
            lowerbound=`cat ftp/ftp.log | grep 200 -n | cut -d ':' -f1`
            upperbound=`cat ftp/ftp.log | grep 226 -n | cut -d ':' -f1`
            lines=$((upperbound-lowerbound))
            cat ftp/ftp.log | grep 200 -A $lines
            echo "[*] Attempting to fetch all files recursively (Under ftp folder)"
            cd ftp
            wget -r ftp://anonymous:@$ip 2>/dev/null 1>/dev/null &
            cd ..
            echo -e $RESET
            echo;
          else
            echo -e "${RED}[-] Anonymous Login Failed... Continuing...${RESET}"
          fi
          echo;
        elif [ $port -eq 22 ]; then
          echo -e "${YELLOW}[!] Detected SSH Service...${RESET} "
          echo -n -e "${GREEN}[*] Fingerprinting Version.. "; timeout 1  nc $ip $port
          echo -e "${RESET}${YELLOW}[?] Test credentials here later or use hydra for online password cracking...${RESET}"
          echo;
        elif [ $port -eq 80 ] || [ $port -eq 443 ]; then
          echo -e "${YELLOW}[+] Detected Web Server..."
          curl $ip:$port -D web/headers.$port 1>/dev/null 2>/dev/null
          echo -n "[+] Web Server: "; cat web/headers.$port | grep "Server:" | cut -d ":" -f2
          if [ `cat web/headers.$port | grep "X-Powered-By" -c` -gt 0 ]; then
            echo -n "[+] Powered By: "; cat web/headers.$port | grep "X-Powered-By:" | cut -d ":" -f2
          else
            echo -e "${RESET}${RED}[-] X-Powered-By Header Missing${YELLOW}"
          fi
          echo -n "[+] Title: "; curl $machine_name.$ext 2>/dev/null | grep "<title>" | sed "s/<title>//g" | sed "s/<\/title>//g"
          echo;

          echo -e "[*] Checking for robots.txt entries.${RESET}"
          curl -D web/robot.headers.$port $machine_name.$ext:$port/robots.txt 2>/dev/null 1>/dev/null
          res=`head -n 1 web/robot.headers.$port | grep 404 -c`
          if [ $res -gt 0 ]; then
            echo -e "${RED}[-] robots.txt not found${RESET}"
          else
            echo -e "${GREEN}[+] Retrieving robots.txt entries..."
            wget $ip:$port/robots.txt -O web/robots.txt.$port 1>/dev/null 2>/dev/null 
            cat web/robots.txt.$port
            echo -e "${RESET}"
          fi
          echo;
          echo -e "${YELLOW}[*] Checking for .well-known entries.${RESET}"
          curl -D web/security.headers.$port $machine_name.$ext:$port/.well-known/security.txt 2>/dev/null 1>/dev/null
          res=`head -n 1 web/security.headers.$port | grep 404 -c`
          if [ $res -gt 0 ]; then
            echo -e "${RED}[-] security.txt not found${RESET}"
          else
            echo -e "${GREEN}[+] Retrieving security.txt entries..."
            wget $machine_name.$ext:$port/.well-known/security.txt -O web/security.txt.$port 1>/dev/null 2>/dev/null 
            cat web/security.txt.$port
            echo -e "${RESET}"
          fi
          if [ $port = 443 ];then
            proto="https://"
          else
            proto="http://"
          fi
          echo -e "${YELLOW}[*] Executing gobuster... Results saved at gobuster.log"
          xterm -e bash -c "gobuster dir -x php,html,sh,bin,txt -w/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u $proto$machine_name.$ext --wildcard | tee gobuster.log" &
          echo -e "[*] Executing nikto... Results saved at nikto.log${RESET}"
          xterm -e bash -c "nikto --url $proto$machine_name.$ext | tee nikto.log" &
          echo;
          echo -e "${GREEN}[+] Connecting to port: $port ${RESET}"
          firefox $proto$machine_name.$ext 1>/dev/null 2>/dev/null &
          echo;
        else
          echo -e "${YELLOW}[!] Unknown Port Detected. Attempting to Fingerprint...${RESET}"
          sudo nmap $pn -sV -sC $machine_name.$ext -p$port | tee nmap/$port.fingerprint 1>/dev/null
          echo -e "${GREEN}[+] Fingerprint Successful..."
          lowerbound=`cat nmap/$port.fingerprint | grep "PORT" -n | cut -d ':' -f1`
          upperbound=`cat nmap/$port.fingerprint | grep "Service detection performed." -n | cut -d ':' -f1`
          upperbound=$((upperbound-1))
          sed -n ${lowerbound},${upperbound}p nmap/$port.fingerprint
          echo -e "${RESET}"
          echo;
        fi
      
      done;
    fi
  fi
  # Check for nmap OS detection.
  if [ $osdone = 0 ]; then
    if [ `cat nmap/os.detection | grep "OS detection performed." -c` -gt 0 ]; then
      echo -e "${GREEN}[+] Fingerprinting OS..."
      lowerbound=`cat nmap/os.detection | grep "tcp" -n | tail -n 1 | cut -d ':' -f1`
      upperbound=`cat nmap/os.detection | grep "OS detection performed." -n | cut -d ':' -f1`
      lowerbound=$((lowerbound+1))
      upperbound=$((upperbound-1))
      sed -n ${lowerbound},${upperbound}p nmap/os.detection
      osdone=1
      echo -e "${RESET}"
    fi 
  fi
  # Finish Script Off
  if [ $osdone -gt 0 ] && [ $portscandone -gt 0 ]; then
    echo -e "${GREEN}[*] Enumeration Completed!${RESET}"
    break;
  fi
done;
