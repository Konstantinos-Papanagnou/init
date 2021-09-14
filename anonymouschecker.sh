#!/bin/bash
host={ip}
user='anonymous'
pass=’’

ftp -n -v $host<< EOT
ascii
user $user $pass
prompt
ls -la
EOT

