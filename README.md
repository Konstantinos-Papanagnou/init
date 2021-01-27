# init
 init script to setup basic files and folders and begin basic enumeration on ctf machines

 
## Basic Usage:
./init {machine_name} {ip}

## Requirements:
	A reverse php script on /opt/reverse_shells/reverse.php
	A misc.txt file with any scripts you'd like on /opt/reverse_shells/misc.txt
	
	In misc.txt the ip should be {ip} for the script to automatically change it with your ip and in reverse.php the ip should be {UPDATE} in order to be replaced
	Feel free to modify the scripts to your needs
	
	This script also uses pluma text editor to open files. If you don't have pluma installed or your system and don't want to install it you can change the text editor.
	for example if you want sublime just replace pluma with sublime
	

# This script is still under developement 
