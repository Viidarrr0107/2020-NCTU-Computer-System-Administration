# Homework 5 - NIS & NFS

## NIS client
```sh
sudo vim /etc/hosts # ADD: 10.113.0.199 sahw5.nctu.cs
sudo vim /etc/rc.conf 
# ADD:
# 	nisdomainname="sahw5.nctu.cs"
# 	nis_client_enable="YES"
#	nis_client_flags="-s -m -S sahw5.nctu.cs,10.113.0.199"
sudo vim /etc/group # ADD: +:*::
sudo vim /etc/master.passwd # ADD: +:*::::::::
sudo /etc/netstart # restart the network, OR reboot directly
sudo service ypbind start # OR reboot directly
# CHECK: ypwhich,  rpcinfo -p sahw5.nctu.cs
# DEBUG: ps aux | grep -i <STR>
```
## NFS client(1/2) - Set up NFS client 
```sh
# REF: showmount -e sahw5.nctu.cs
sudo vim /etc/autofs/hw5.map # see appendix/hw5.map
sudo vim /etc/auto_master # ADD: /- /etc/autofs/hw5.map
sudo vim /etc/rc.conf # ADD: autofs_enable="YES"
sudo reboot
# CHECK: login nisuser1, nisuser2, nisstu95
```
## NFS client(2/2) - Web Page 
```sh
sudo vim /usr/local/bin/uploadscript.sh # see appendix/uploadscript.sh
sudo vim /usr/local/etc/nginx/nginx.conf # see appendix/nginx.conf
sudo service nginx restart
```
## NIS & NFS Server
Server Machine
```sh
sudo vim /etc/rc.conf
# ADD:
# 	nisdomainname="95.sahw5.nctu.cs"
# 	nis_server_enable="YES"
#	nis_yppasswdd_enable="YES"
#	nis_client_enable="YES"
#	rpcbind_enable="YES"
#	nfs_server_enable="YES"
#	nfsv4_server_enable="YES"
#	nfs_server_flags="-u -t -n 4"
#	mountd_enable="YES"
#	nfs_reserved_port_only="YES"
sudo adduser # add 3 users, nisuser1 nisuser2 nisstu95
sudo cp /etc/master.passwd /var/yp/master.passwd
sudo vim /var/yp/master.passwd # RM: not NIS user
sudo domainname 95.sahw5.nctu.cs
sudo service ypserv start
sudo ypinit -m 95.sahw5.nctu.cs

sudo vim /etc/exports
# ADD:
#	/net/home/nisuser1 /net/home/nisuser2 -maproot=nobody -network 10.113.0.0 -mask 255.255.255.0
#	/net/home/nisstu95 /net/data/95 -maproot=nobody -network 10.113.0.95 -mask 255.255.255.255
#	V4:/
```
Client Machine
```sh
sudo vim /etc/hosts # ADD: 10.113.254.95 95.sahw5.nctu.cs
sudo vim /etc/rc.conf 
# ADD:
# 	nisdomainname="95.sahw5.nctu.cs"
# 	nis_client_enable="YES"
#	nis_client_flags="-s -m -S 95.sahw5.nctu.cs,10.113.254.95"
sudo vim /etc/group # ADD: +:*::
sudo vim /etc/master.passwd # ADD: +:*::::::::
# reboot
```