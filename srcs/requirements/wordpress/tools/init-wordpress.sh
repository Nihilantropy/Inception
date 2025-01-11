#!/bin/bash
set -e

# Only install WP-CLI if not already installed
if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

mkdir -p /var/www/html

# Only download and install WordPress if not already present
cd /var/www/html
if [ ! -f "wp-load.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Installing WordPress..."
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USR" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
        
    # Create additional user
    wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root

    # Install and activate theme and plugin
    wp theme install astra --activate --allow-root
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
fi

chown -R www-data:www-data /var/www/html
chmod 755 /var/www/html

# Configure PHP-FPM
sed -i -r 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf
mkdir -p /run/php

# Execute the database setup and start PHP-FPM
exec /usr/local/bin/setup_db.sh