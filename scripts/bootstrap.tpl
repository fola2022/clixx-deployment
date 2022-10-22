#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

##variable
#rds_endpoint=data.aws_db_instance.wordpress.endpoint
#loadbalancer=clixx-lb-1680609739.us-east-1.elb.amazonaws.com


####mount EFS
# yum -y update
# yum install -y amazon-efs-utils
# yum -y install nfs-utils
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}
mount -t efs "${FILE_SYSTEM_ID}":/ ${MOUNT_POINT}
chmod -R 755 ${MOUNT_POINT}
# amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2


##Install the needed packages and enable the services(MariaDb, Apache)
#sudo yum update -y
#yum install git -y
#amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
# yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
systemctl is-enabled httpd

##Add ec2-user to Apache group and grant permissions to /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
cd /var/www/html


git clone https://github.com/stackitgit/CliXX_Retail_Repository.git
cp -r CliXX_Retail_Repository/* /var/www/html

## set Wordpress to run in an alternative directory
DB_HOST=$(cat ${CONFIG_FILE} | grep DB_HOST | cut -d\' -f 4)

if [[ ${rds_endpoint} == $${DB_HOST} ]]; then
        echo "True" > /home/ec2-user/checks.txt
else
    sudo sed -i "s/$${DB_HOST}/${rds_endpoint}/g" ${CONFIG_FILE}

fi


## Allow wordpress to use Permalinks
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf

##Grant file ownership of /var/www & its contents to apache user
sudo chown -R apache /var/www

##Grant group ownership of /var/www & contents to apache group
sudo chgrp -R apache /var/www

##Change directory permissions of /var/www & its subdir to add group write
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;

##Recursively change file permission of /var/www & subdir to add group write perm
sudo find /var/www -type f -exec sudo chmod 0664 {} \;

##Restart Apache
sudo systemctl restart httpd
sudo service httpd restart

##Enable httpd
sudo systemctl enable httpd
sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=200 net.ipv4.tcp_keepalive_intvl=200 net.ipv4.tcp_keepalive_probes=5


#####login to sql and update the the url with the LB A-record

database=$(mysql -h ${rds_endpoint} -P 3306 -u ${DB_USER} -p${DB_PASS} -D ${DB_NAME} -BNe "SELECT  option_value FROM wp_options WHERE option_name = 'siteurl'";)
if [[ ${LOADBALANCER} == $${database} ]];
then
    echo "Already Updated" >> /home/ec2-user/checks.txt
else
    mysql -h ${rds_endpoint} -P 3306 -u ${DB_USER} -p${DB_PASS} -D ${DB_NAME} -BNe "UPDATE wp_options SET option_value ='${LOADBALANCER}' WHERE option_value LIKE 'http%'";
fi


#mysql -h clixx-apps-db.c0rdyufv2vjv.us-east-1.rds.amazonaws.com -P 3306 -u wordpressuser -pW3lcome123 -D wordpressdb