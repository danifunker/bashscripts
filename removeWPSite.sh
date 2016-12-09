#!/bin/bash
test "$EUID" -ne 0 && echo "Please run sudo $0" && exit
s3configbucket="s3bucketnamehere"
sqlserver="sqlserver-goes-here"
mysqlrootuser="rootusernamehere"
mysqlrootpassword="rootpasswordhere"
test $# -lt 1 && read -e -p "Enter the internal wordpress sitename to be removed: " && sitename=$REPLY 
if test $# -eq 1 ; then
	sitename=$1
fi

rm -f /etc/httpd/conf.d/$sitename.conf
#reload the httpd server
service httpd reload

#continue removing additional components from the site
rm -rf /var/www/$sitename
rm -rf /var/log/httpd/$sitename*.*
aws --region us-east-2 s3 rm s3://$s3configbucket/confs/$sitename.conf

#remove the MySQL database
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "DROP DATABASE ${sitename};"
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "DROP USER ${sitename}@'%';"
mysql -h $sqlserver -u $mysqlrootuser -p$mysqlrootpassword -e "FLUSH PRIVILEGES;" 


echo "Removal for site $sitename completed. Please navigate to $url to ensure the site is no longer running."