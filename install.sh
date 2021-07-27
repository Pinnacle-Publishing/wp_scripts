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
chown -R ${SITE_NAME}:${SITE_NAME} /var/www/${SITE_NAME}/public_html/


# Create database
echo ".... Create new database ....."
PASS=$(openssl rand -base64 16)

echo $PASS >> ./${SITE_NAME}.txt

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

certbot --nginx -d "${DOMAIN}" -d "www.${DOMAIN}"


echo "Restart Service"

systemctl restart php7.4-fpm
systemctl restart nginx
