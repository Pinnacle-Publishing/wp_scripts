#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

apt update
apt install -y python3 python3-pip nginx php7.4-fpm wget mariadb-server
pip install jinja2 validators

echo ".... Installing nginx domain ....."
python3 main.py $1

echo "...... Done ....."


# Create user

# Create database


read -p "Do yoy want to install wordpress for $1? " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Y]$ ]]
then
  exit 1
fi

echo ".... Downloading latest wordpress ....."
wget https://wordpress.org/latest.tar.gz

echo "..... Unzipping file ....."
tar xvf latest.tar.gz

IFS='.'
read -a strarr <<<"$1"

echo "..... Installing wordpress ${strarr[0]}....."

mkdir -p "/var/wwww/${strarr[0]}/public_html/"
cp -r wordpress/* "/var/wwww/${strarr[0]}/public_html/"

echo "..... clean up ....."
rm -rf latest.tar.gz
rm -rf wordpress
echo "..... Done ....."


read -p "Do yoy want to install certbot for $1? " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Y]$ ]]
then
  exit 1
fi

certbot --nginx -d $1 -d www.$1

# restart service
