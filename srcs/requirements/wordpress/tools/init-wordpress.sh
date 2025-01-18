#!/bin/bash
set -e

echo "=== Starting WordPress Initialization ==="

echo "1. Setting up WP-CLI..."
if [ ! -f "/usr/local/bin/wp" ]; then
    echo "- Downloading WP-CLI..."
    if curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; then
        echo "- Making WP-CLI executable..."
        chmod +x wp-cli.phar
        echo "- Moving WP-CLI to system path..."
        mv wp-cli.phar /usr/local/bin/wp
        echo "✅ WP-CLI installed successfully"
    else
        echo "❌ ERROR: Failed to download WP-CLI!"
        exit 1
    fi
else
    echo "✅ WP-CLI already installed"
fi

echo "2. Setting initial permissions..."
echo "- Setting ownership of web root..."
chown -R www-data:www-data /var/www/html
echo "- Setting directory permissions..."
find /var/www/html -type d -exec chmod 755 {} \;
echo "- Setting file permissions..."
find /var/www/html -type f -exec chmod 644 {} \;
echo "✅ Initial permission are set correctly"

echo "3. Preparing web root directory..."
mkdir -p /var/www/html
cd /var/www/html

echo "4. Installing WordPress core..."
if [ ! -f "wp-load.php" ]; then
    echo "- Downloading WordPress..."
    if ! wp core download --allow-root; then
        echo "❌ ERROR: Failed to download WordPress!"
        exit 1
    fi
    
    echo "- Installing WordPress..."
    if ! wp core install \
        --path=/var/www/html \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USR" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root; then
        echo "❌ ERROR: WordPress installation failed!"
        exit 1
    fi
    echo "✅ WordPress core installed successfully"
    
    echo "5. Creating additional user..."
    if ! wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root --path=/var/www/html; then
        echo "❌ ERROR: Failed to create additional user!"
        exit 1
    fi
    echo "✅ Additional user created successfully"

    echo "6. Installing theme..."
    if ! wp theme install astra --activate --allow-root --path=/var/www/html; then
        echo "❌ ERROR: Theme installation failed!"
        exit 1
    fi
    echo "✅ Theme installed successfully"
    
    echo "7. Setting up Redis cache..."
    echo "- Installing Redis plugin..."
    if ! wp plugin install redis-cache --activate --allow-root --path=/var/www/html; then
        echo "❌ ERROR: Redis plugin installation failed!"
        exit 1
    fi
    
    echo "- Creating uploads directory..."
    mkdir -p wp-content/uploads
    chown -R www-data:www-data wp-content/uploads
    chmod 755 wp-content/uploads
    
    echo "- Configuring object cache..."
    if [ -f "wp-content/plugins/redis-cache/includes/object-cache.php" ]; then
        cp wp-content/plugins/redis-cache/includes/object-cache.php wp-content/object-cache.php
        chown www-data:www-data wp-content/object-cache.php
        chmod 644 wp-content/object-cache.php
    else
        echo "❌ ERROR: object-cache.php not found!"
        exit 1
    fi

    echo "- Setting Redis permissions..."
    chown -R www-data:www-data wp-content/plugins/redis-cache
    chmod -R 755 wp-content/plugins/redis-cache
    
    echo "- Updating Redis plugin..."
    wp plugin update redis-cache --allow-root --path=/var/www/html
    
    echo "- Enabling Redis..."
    wp redis enable --allow-root --path=/var/www/html || true
    echo "✅ Redis cache setup completed"
fi

echo "8. Setting final permissions..."
echo "- Setting wp-content permissions..."
chmod -R 775 /var/www/html/wp-content
echo "✅ All permissions set correctly"

echo "9. Configuring PHP-FPM..."
echo "- Setting PHP-FPM user and group..."
sed -i -r 's|^user = .*$|user = www-data|' /etc/php81/php-fpm.d/www.conf
sed -i -r 's|^group = .*$|group = www-data|' /etc/php81/php-fpm.d/www.conf
sed -i -r 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf

echo "- Creating PHP-FPM runtime directory..."
mkdir -p /run/php
chown -R www-data:www-data /run/php
echo "✅ PHP-FPM configured successfully"

echo "=== WordPress initialization complete. Starting database setup... ==="

# Execute the database setup and start PHP-FPM
exec /usr/local/bin/setup_db.sh