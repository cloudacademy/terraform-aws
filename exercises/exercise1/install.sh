#!/bin/bash
apt-get -y update
apt-get -y install nginx
service nginx start
echo fin v1.00!