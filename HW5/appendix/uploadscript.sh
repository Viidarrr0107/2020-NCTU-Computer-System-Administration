#!/bin/sh
username=$UPLOAD_USER
if [ "${username}" = "ftp" ]; then
	username="Anonymous"
fi
echo "$(date): $username has uploaded file $1 with size $UPLOAD_SIZE" >> /var/log/uploadscript.log
echo "$(date): $username has uploaded file $1 with size $UPLOAD_SIZE" >> /net/home/nisstu95/public_html/uploadscript.log