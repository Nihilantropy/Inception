#!/bin/sh
set -e

# Download and set up Adminer if not already present
if [ ! -f "/var/www/html/index.php" ]; then
    echo "Downloading Adminer..."
    cd /var/www/html
    wget "http://www.adminer.org/latest.php" -O index.php
    chown -R www-data:www-data /var/www/html
    chmod 775 index.php
fi

# Configure Apache virtual host
echo "Configuring Apache..."
# Add global ServerName
echo "ServerName localhost" >> /etc/apache2/httpd.conf

cat > /etc/apache2/conf.d/adminer.conf << 'EOF'
<VirtualHost *:8080>
    ServerName localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Redirect /adminer.php to index.php for healthcheck
        RedirectMatch 301 ^/adminer\.php$ /
    </Directory>

    ErrorLog /dev/stderr
    CustomLog /dev/stdout combined
</VirtualHost>
EOF

# Configure Apache
echo "Setting up Apache configuration..."
sed -i \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/Listen 80/Listen 8080/' \
    -e 's/User apache/User www-data/' \
    -e 's/Group apache/Group www-data/' \
    /etc/apache2/httpd.conf

# Configure PHP
echo "Configuring PHP..."
sed -i \
    -e 's/;extension=pdo_mysql/extension=pdo_mysql/' \
    -e 's/;extension=mysqli/extension=mysqli/' \
    /etc/php81/php.ini

# Set proper permissions
echo "Setting permissions..."
chown -R www-data:www-data /run/apache2 /var/www/html /var/log/apache2

# Create a symlink for healthcheck
ln -sf /var/www/html/index.php /var/www/html/adminer.php

echo "Starting Apache..."
# Start Apache in foreground
exec httpd -D FOREGROUND