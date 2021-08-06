#!/bin/bash

echo Making init.sh executable...
chmod +x init.sh

echo Copying reverse shells into /opt/reverse_shells/
cp -r reverse_shells/ /opt/reverse_shells/

echo Creating symlink for init.sh
ln -s $(pwd)/init.sh /bin/initWorkspace

echo Everything\'s setup! Simply run initWorkspace to get started!
