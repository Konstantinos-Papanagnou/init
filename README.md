# Old init
 init script to setup basic files and folders and begin automated enumeration on ctf machines
##### Manual Enumeration only provided

# New init
#### Automated the whole process of enumeration. FTP enumeration and anonymous login and automatically fetching the entire ftp folder recursively.
#### Real time results as nmap scans.
#### Auto enumeration on web servers.
#### Auto enumeration on port services.
#### Auto enumeration on unknown services.


## Installation:
#### This tool now requires installation. No Additional Libraries needed. To install:
```bash
chmod +x setup.sh
sudo ./setup.sh
```
#### It's really that Simple!

## Basic Usage:
### For the new automated script: 
```bash
initWorkspace <machine name> <ip> [extention thm,htb,local whatever applies.]
```

### For the old manual script:
```bash
initmanualWorkspace <machine name> <ip> [extention thm,htb,local whatever applies.]
```


# This script is still under developement 
