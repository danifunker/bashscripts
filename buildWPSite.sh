#!/bin/bash
test "$EUID" -ne 0 && echo "Please run sudo $0" && exit
s3configbucket="s3bucketnamehere"
sqlserver="sqlserver-goes-here"
mysqlrootuser="rootusernamehere"
mysqlrootpassword="rootpasswordhere"
test $# -lt 2 && read -e -p "Enter the internal wordpress sitename to be used for reference: " && sitename=$REPLY && read -e -p "Enter the external URL to be used for this site (exclude www): " && url=$REPLY
if test $# -eq 2 ; then
	sitename=$1
	url=$2
fi

#Create the MySQL database
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "CREATE DATABASE ${sitename};"
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "CREATE USER ${sitename}@'%' IDENTIFIED BY '${sitename}';"
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "GRANT ALL PRIVILEGES ON ${sitename}.* to ${sitename}@'%'"
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "FLUSH PRIVILEGES;" 

mkdir -p /var/www/$sitename
curl https://wordpress.org/latest.tar.gz -o /var/www/$sitename/$sitename.tgz
tar zxf /var/www/$sitename/$sitename.tgz -C /var/www/$sitename
rm -f /var/www/$sitename/$sitename.tgz
chmod -R 755 /var/www/$sitename
chown apache:apache /var/www/$sitename

#add httpd configuration to the server
aws --region us-east-2 s3 cp s3://$s3configbucket/apache-wp-template.conf /etc/httpd/conf.d/$sitename.conf
sed -i "s/SITENAME/$sitename/g" /etc/httpd/conf.d/$sitename.conf
sed -i "s/URLNAME/$url/g" /etc/httpd/conf.d/$sitename.conf
aws --region us-east-2 s3 cp /etc/httpd/conf.d/$sitename.conf s3://$s3configbucket/confs/$sitename.conf

#Set the wordpress configuration
cp -f /var/www/$sitename/wordpress/wp-config-sample.php /var/www/$sitename/wordpress/wp-config.php
sed -i "s/database_name_here/$sitename/g" /var/www/$sitename/wordpress/wp-config.php
sed -i "s/username_here/$sitename/g" /var/www/$sitename/wordpress/wp-config.php
sed -i "s/password_here/$sitename/g" /var/www/$sitename/wordpress/wp-config.php
sed -i "s/localhost/$sqlserver/g" /var/www/$sitename/wordpress/wp-config.php

#reload the httpd server
service httpd reload

echo "Configuration for site $sitename completed. Please navigate to $url to finalize the WordPress setup."