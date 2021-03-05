# init
 init script to setup basic files and folders and begin basic enumeration on ctf machines

## Installation:
#### In case you want it to exist on your path (aka. install it) you can simply run: `chmod +x setup.sh` and `sudo ./setup.sh`
Note: The reverse_shells need to be in /opt/reverse_shells. The setup will automatically copy them to the correct location. 
If you don't want to run setup you need to run `sudo cp -r /installation_path/reverse_shells/ /opt/reverse_shells/`
 
## Basic Usage:
./init {machine_name} {ip}

## Requirements:
	The reverse scripts are now shipped alongside with the script so it's not required to download them and create them yourself.
	
	In misc.txt & reverse.php the ip should be {ip} for the script to automatically change it with your ip
	Feel free to modify the scripts to your needs
	
	This script also uses pluma text editor to open files. If you don't have pluma installed or your system and don't want to install it you can change the text editor.
	for example if you want sublime just replace pluma with sublime
	

# This script is still under developement 
