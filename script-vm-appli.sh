
#!/bin/bash -x

sudo apt update
sudo apt -y install wget
sudo apt -y install bzip2

# Apache installation
sudo apt -y install apache2
sudo apt -y install php libapache2-mod-php php-mysql php-xml php-cli php-gd php-curl php-zip php-mbstring php-bcmath

# Application installation
sudo wget -O /tmp/latest.tar.bz2 https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -xjvf /tmp/latest.tar.bz2 -C /tmp
sudo mv /tmp/nextcloud /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud

echo "<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www/nextcloud
  ErrorLog /error.log
  CustomLog /access.log combined
</VirtualHost>" > /etc/apache2/sites-available/nextcloud.conf

# Configuration
sudo a2dissite 000-default.conf
sudo a2ensite nextcloud.conf
sudo systemctl restart apache2

sudo awk '{ print } "0 =>" { print "1 => 'esan-preproduction-nextcloud.westeurope.cloudapp.azure.com'," }' /var/www/nextcloud/config/config.php

