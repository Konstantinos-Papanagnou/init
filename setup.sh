#!/bin/bash

apt update
apt install xterm

echo Making init.sh executable...
chmod +x init.sh

echo Creating Directories
mkdir /opt/init
mkdir /opt/init/reverse_shells

echo Copying reverse shells into /opt/init/reverse_shells/
cp -r reverse_shells/ /opt/init/

echo Copying anonymouschecker.sh to /opt/init
cp anonymouschecker.sh /opt/init/

echo Creating symlink for init.sh
ln -s $(pwd)/init.sh /bin/initWorkspace

echo Creating symlink for manual_init.sh
ln -s $(pwd)/manual_init.sh /bin/initmanualWorkspace

echo Everything\'s setup! Simply run initWorkspace to get started!
