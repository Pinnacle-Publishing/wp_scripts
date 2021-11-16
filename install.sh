#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php

apt update
apt install -y python3 python3-pip nginx php7.4-fpm wget mariadb-server php7.4-mysql
pip install jinja2 validators requests

echo ".... Installing nginx domain ....."
python3 main.py $1

echo "...... Done ....."

DOMAIN=$1

IFS='.'
read -a strarr <<<"$1"

if [ ${#strarr[@]} -eq 3 ]
then
    SITE_NAME=${strarr[1]}
else
    SITE_NAME=${strarr[0]}
fi


# Create user
echo "Add user ${SITE_NAME}"
useradd ${SITE_NAME}

# Create database
echo ".... Create new database ....."
PASS=$(cat "${SITE_NAME}.txt" | xargs)
echo "${PASS}"

./database.sh ${SITE_NAME} ${SITE_NAME} ${PASS}


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

echo "..... Installing wordpress ${SITE_NAME}....."

mkdir -p "/var/www/${SITE_NAME}/public_html/"
cp -r wordpress/* /var/www/${SITE_NAME}/public_html/

chown -R ${SITE_NAME}:${SITE_NAME} /var/www/${SITE_NAME}/public_html/
chmod -R 775 /var/www/${SITE_NAME}/public_html/

echo "..... clean up ....."
rm -rf latest.tar.gz
rm -rf wordpress

python3 password.py "${DOMAIN}"


echo "Restart Service"

systemctl restart php7.4-fpm
systemctl restart nginx


read -p "Do yoy want to install certbot for $1? " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Y]$ ]]
then
  exit 1
fi

certbot --nginx -d "${DOMAIN}"

echo "Restart Service"

systemctl restart php7.4-fpm
systemctl restart nginx

echo "..... Done ....."
