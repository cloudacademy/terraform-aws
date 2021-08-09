#!/bin/bash
apt-get -y update
apt-get -y install nginx
#service nginx start
systemctl start nginx
echo fin v1.00!