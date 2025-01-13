#!/bin/bash
set -e

# Only install WP-CLI if not already installed
if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Ensure proper directory ownership and permissions from the start
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

mkdir -p /var/www/html
cd /var/www/html

# Only download and install WordPress if not already present
if [ ! -f "wp-load.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Installing WordPress..."
    wp core install \
        --path=/var/www/html \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USR" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
        
    # Create additional user
    wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root --path=/var/www/html

    # Install and activate theme and plugins
    wp theme install astra --activate --allow-root --path=/var/www/html
    
    # Install and configure Redis
    echo "Starting Redis plugin installation..."
    wp plugin install redis-cache --activate --allow-root --path=/var/www/html
    echo "Redis plugin installation completed"
    
    # Create wp-content/uploads directory with proper permissions
    mkdir -p wp-content/uploads
    chown -R www-data:www-data wp-content/uploads
    chmod 755 wp-content/uploads
    
    # Copy the object cache file
    if [ -f "wp-content/plugins/redis-cache/includes/object-cache.php" ]; then
        echo "Copying object-cache.php..."
        cp wp-content/plugins/redis-cache/includes/object-cache.php wp-content/object-cache.php
        chown www-data:www-data wp-content/object-cache.php
        chmod 644 wp-content/object-cache.php
    else
        echo "ERROR: object-cache.php not found!"
    fi

    # Set proper permissions for Redis cache
    chown -R www-data:www-data wp-content/plugins/redis-cache
    chmod -R 755 wp-content/plugins/redis-cache
    
    # Update the plugin
    wp plugin update redis-cache --allow-root --path=/var/www/html
    
    # Enable Redis
    wp redis enable --allow-root --path=/var/www/html || true
fi

# Final permission setup for all WordPress files
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Make sure wp-content is writable
chmod -R 775 /var/www/html/wp-content

# Configure PHP-FPM to run as www-data
echo "Configuring PHP-FPM to use www-data user and group..."
sed -i -r 's|^user = .*$|user = www-data|' /etc/php81/php-fpm.d/www.conf
sed -i -r 's|^group = .*$|group = www-data|' /etc/php81/php-fpm.d/www.conf
sed -i -r 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf

# Create PHP-FPM runtime directories
mkdir -p /run/php
chown -R www-data:www-data /run/php

# Execute the database setup and start PHP-FPM
exec /usr/local/bin/setup_db.sh