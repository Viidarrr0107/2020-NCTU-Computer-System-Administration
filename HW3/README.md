# Part 3-1

## Install ports
```sh
sudo portsnap fetch
sudo portsnap extract
cd /usr/ports/ports-mgmt/pkg
sudo make
sudo make reinstall
```
---
## Install pure-ftpd
```sh
# install pure-ftpd
cd /usr/ports/ftp/pure-ftpd
sudo make install clean
sudo vim /etc/rc.conf # see appendix/rc.conf
```
---
## Modify configuration of pure-ftpd
```sh
sudo cp /usr/local/etc/pure-ftpd.conf.sample /usr/local/etc/pure-ftpd.conf
# HINT: cat /usr/local/etc/pure-ftpd.conf | grep -n PureDB; vim +<lineNUM> /usr/local/etc/pure-ftpd.conf
sudo vim /usr/local/etc/pure-ftpd.conf 
# MODIFY:
# 	ChrootEveryone    yes
# 	AnonymousOnly    no
# 	NoAnonymous    no
# 	PureDB    /usr/local/etc/pureftpd.pdb
# 	AnonymousCanCreateDirs    no
# 	AntiWarez    no
# 	AnonymousCantUpload    no
# 	CertFile    /etc/ssl/private/pure-ftpd.pem
sudo touch /usr/local/etc/pureftpd.passwd
sudo touch /usr/local/etc/pureftpd.pdb
```
---
## Create system account
```sh
sudo pw groupadd ftpadmin # highest privilege
sudo pw groupadd ftpvip #
sudo pw groupadd ftpgroup # low privilege
sudo pw useradd ftp -g ftpgroup -d /home/ftp -s /usr/sbin/nologin # anonymous
sudo pw useradd sysadm -g ftpadmin -d /home/ftp -s /bin/sh
sudo passwd sysadm
sudo pw useradd ftp-vip1 -g ftpgroup -G ftpvip -d /home/ftp -s /usr/sbin/nologin
sudo pw useradd ftp-vip2 -g ftpgroup -G ftpvip -d /home/ftp -s /usr/sbin/nologin
# CHECK: cat /etc/passwd; cat /etc/group
```
---
## Create directory and do AC 
```sh
sudo mkdir /home/ftp
sudo chown sysadm:ftpgroup /home/ftp

sudo mkdir /home/ftp/public
sudo chown sysadm:ftpadmin /home/ftp/public
sudo chmod 777 /home/ftp/public

sudo mkdir /home/ftp/upload
sudo chown sysadm:ftpgroup /home/ftp/upload
sudo chmod 1777 /home/ftp/upload

sudo mkdir /home/ftp/hidden
sudo chown sysadm:ftpvip /home/ftp/hidden
sudo chmod 771 /home/ftp/hidden
```
---
## Create virtual account
```sh
sudo pure-pw useradd sysadm -u sysadm -d /home/ftp -f /usr/local/etc/pureftpd.passwd
sudo pure-pw useradd ftp-vip1 -u ftp-vip1 -d /home/ftp -f /usr/local/etc/pureftpd.passwd
sudo pure-pw useradd ftp-vip2 -u ftp-vip2 -d /home/ftp -f /usr/local/etc/pureftpd.passwd
sudo pure-pw mkdb /usr/local/etc/pureftpd.pdb -f /usr/local/etc/pureftpd.passwd # commit change
```
---
## Enable TLS
```sh
sudo mkdir /etc/ssl/private
sudo openssl req -x509 -nodes -newkey rsa:2048 -sha256 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
sudo vim /usr/local/etc/pure-ftpd.conf # MODIFY: TLS    2
```
---
# Part 3-2

## Create upload script
```sh
sudo touch /usr/local/bin/uploadscript.sh
sudo chmod +x /usr/local/bin/uploadscript.sh
sudo vim /usr/local/bin/uploadscript.sh # see appendix/uploadscript.sh
sudo vim /usr/local/etc/pure-ftpd.conf # MODIFY: CallUploadScript    yes
```
---
## Create service ftp-watchd
```sh
sudo touch /usr/local/etc/rc.d/ftp-watchd
sudo chmod +x /usr/local/etc/rc.d/ftp-watchd
sudo vim /usr/local/etc/rc.d/ftp-watchd # see appendix/ftp-watchd
```
---
# Part 3-3

Add 2 new VHD to machine.
## Backup /home/ftp and clear /home/ftp
```sh
cd /home/ftp
sudo tar pczvf /home/bakftp.tar.gz .
sudo rm -rf /home/ftp/*
```
## Create a mirror pool and dataset
```sh
sudo zpool create -m /home/ftp mypool mirror /dev/ada1 /dev/ada2
# CHECK: zpool list
sudo zfs create mypool/public
sudo zfs create mypool/upload
sudo zfs create mypool/hidden
# restore /home/ftp
sudo cp /home/bakftp.tar.gz /home/ftp/bakftp.tar.gz
cd /home/ftp
sudo tar pxzvf bakftp.tar.gz
# set PROPERTY
sudo zfs set compression=lz4 mypool
sudo zfs set atime=off mypool
sudo zfs set atime=off zroot/var/mail
# CHECK: zfs get atime; zfs get compression
```
## Create automatic snapshot script: "zfsbak"
```sh
sudo touch /usr/local/bin/zfsbak
sudo chmod +x /usr/local/bin/zfsbak
sudo vim /usr/local/bin/zfsbak # see appendix/zfsbak
```