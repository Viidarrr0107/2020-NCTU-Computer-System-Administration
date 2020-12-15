# Homework 4 - Web Services

## Virtualbox setting
To test this project, the network setting should be changed.

TODO:

add "Virtualbox Host-Only Ethernet Adapter" to VM. (remember MAC)

boot the VM, type `ifconfig`

find the network iface with same MAC

if this interface has no IP, type `sudo dhclient <iface_name>` to get IP from DHCP

## Nginx
```sh
sudo pkg update
pkg search nginx
sudo pkg install nginx
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo vim /etc/rc.conf # MODIFY: nginx_enable="YES"
sudo service nginx start
```
## private page setting
```sh
sudo pkg install py37-htpasswd
sudo mv /use/local/bin/htpasswd.py /use/local/bin/htpasswd

sudo htpasswd -c -b .htpasswd admin <PASSWORD>
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
## HTTPS
```sh
sudo mkdir /usr/local/etc/nginx/ssl
cd /usr/local/etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert.key -out cert.crt
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
## PHP-FPM
```sh
sudo pkg install php73
sudo cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
sudo vim /usr/local/etc/php.ini
# MODIFY: 
#	cgi.fix_pathinfo=0
#	expose_php = Off
sudo vim /usr/local/etc/php-fpm.d/www.conf
# MODIFY:
#	listen.owner = www
#	listen.group = www
#	listen.mode = 0660
#	;listen = 127.0.0.1:9000
#	listen = /var/run/php-fpm.sock
sudo vim /usr/local/www/html/info-95.php # WRITE: <?php phpinfo(); ?>
sudo vim /etc/rc.conf # MODIFY: php_fpm_enable="YES"
sudo service php-fpm start
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
## MySQL
```sh
sudo pkg install mysql80-server
sudo vim /etc/rc.conf # mysql_enable="YES"
sudo service mysql-server start
/usr/local/bin/mysql_secure_installation # do setting
/usr/local/bin/mysql -u root -p # next section
ls -al /var/db/mysql
```
```sql
Enter password:
root@localhost> CREATE USER 'wdpress'@'localhost' IDENTIFIED BY '<PASSWORD>';
root@localhost> CREATE DATABASE `wordpress`;
root@localhost> GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';
root@localhost> GRANT ALL PRIVILEGES ON wordpress.* TO 'wdpress'@'localhost';
root@localhost> FLUSH PRIVILEGES;
root@localhost> quit
```
## Basic App Router
```sh
cd /usr/local/www/html/
sudo mkdir app
sudo touch app/index.php # see appendix/index.php
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
## WebSocket 
```sh
cd ~/Downloads
curl -LO https://github.com/joewalnes/websocketd/releases/download/v0.3.0/websocketd-0.3.0-freebsd_amd64.zip
unzip -d websocketd websocketd-0.3.0-freebsd_amd64.zip
cd websocketd
vim prog.sh
chmod +x prog.sh
##### TMUX #####
./websocketd --port=8080 ./prog.sh
sudo ./websocketd --ssl --sslcert="/usr/local/etc/nginx/ssl/cert.crt" \
	--sslkey "/usr/local/etc/nginx/ssl/cert.key" --port=8081 ./prog.sh
##### TMUX #####
sudo vim /usr/local/www/html/wsdemo/wsdemo.html # see appendix/wsdemo.html
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
prog.sh:
```sh
!/bin/sh
for count in $(seq 1 3); do
	ping -c1 1.1.1.1 | sed -n 2p | awk '{printf("%s\n", substr($7, 6));}'
	sleep 1
done
```
## Wordpress
```sh
# download php extension first
sudo pkg install -y php73-curl php73-dom php73-posix php73-filter php73-ftp php73-gd php73-iconv php73-json \
	php73-mbstring php73-openssl php73-simplexml php73-sockets php73-tokenizer php73-xmlreader \
	php73-zlib php73-mysqli php73-pdo_mysql php73-zip php73-hash
php -m
sudo service php-fpm restart
cd /usr/local/www/nginx
sudo curl -LO https://wordpress.org/latest.zip
unzip latest.zip
sudo chown -R www:www wordpress/
sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php
sudo chown -R www:www wordpress/wp-config.php
sudo vim wordpress/wp-config.php
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
wp-config.php:
```php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wdpress' );
define( 'DB_PASSWORD', '<PASSWORD>' );
```
if the database error occurs during installation, run `mysql -u root -p`:
```sql
Enter password:
root@localhost> set global validate_password.policy=0;
root@localhost> set global validate_password.length=1;
root@localhost> SHOW VARIABLES LIKE 'validate_password%';
root@localhost> ALTER USER 'wdpress'@'localhost' IDENTIFIED WITH mysql_native_password BY '<PASSWORD>';
root@localhost> FLUSH PRIVILEGES;
root@localhost> quit
```
## Before Judge
```sh
service nginx status
service php-fpm status
sudo service mysql-server status
cd ~/Downloads/websocketd
##### TMUX #####
./websocketd --port=8080 ./prog.sh
sudo ./websocketd --ssl --sslcert="/usr/local/etc/nginx/ssl/cert.crt" \
	--sslkey "/usr/local/etc/nginx/ssl/cert.key" --port=8081 ./prog.sh
##### TMUX #####
```
## Machine Structure
- /usr/local/
	- bin/
		- `mysql*`
		- `mysql_secure_installation*`
		- SOMETHINGELSE
	- etc/
		- nginx/
			- `nginx.conf`
			- ssl/
				- `cert.crt`
				- `cert.key`
			- SOMETHINGELSE
		- `php-fpm.conf`
		- php-fpm.d/
			- `www.conf`
		- `php.conf`
		- `php-ini`
		- `php.ini-development`
		- `php.ini-production`
		- mysql/
	- www/
		- html/
			- `index.html`
			- `vhost.html`
			- `info-95.php`
			- app/
				- `index.php`
			- wsdemo/
				- `wsdemo.html`
		- `nginx@ -> /usr/local/www/nginx-dist`
		- nginx-dist/
			- wordpress/
				- `wp-config.php`
				- SOMETHINGELSE

- $HOME/Downloads/websocketd
	- `websocketd*`
	- `prog.sh*`