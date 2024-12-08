#!/bin/sh
set -e

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

mkdir -p /var/www/html

# Download WordPress
cd /var/www/html
wp core download --allow-root

# Install WordPress
wp core install \
    --url="$DOMAIN_NAME" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USR" \
    --admin_password="$WP_ADMIN_PWD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

chown -R www-data:www-data /var/www/html &&\
chmod 755 /var/www/html

# Create an additional user
wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root

# Install and activate theme and plugin
wp theme install astra --activate --allow-root
wp plugin install redis-cache --activate --allow-root

# Enable Redis Cache
wp redis enable --allow-root

# Configure PHP-FPM
sed -i -r 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf
mkdir -p /run/php

# Run setup script
exec /usr/local/bin/setup_db.sh
