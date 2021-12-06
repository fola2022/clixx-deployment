#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#exec > >(tee /var/log/userdata.log) 2>&1

sudo yum install -y httpd mariadb-server
sudo yum install -y php php-mysql
sudo systemctl start mariadb

