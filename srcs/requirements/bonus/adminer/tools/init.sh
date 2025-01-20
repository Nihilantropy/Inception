#!/bin/sh
set -e

echo "=== Starting Adminer Initialization ==="

echo "1. Setting up Adminer..."
if [ ! -f "/var/www/html/index.php" ]; then
    echo "- Downloading latest version of Adminer..."
    cd /var/www/html
    if wget "http://www.adminer.org/latest.php" -O index.php; then
        echo "- Setting proper ownership..."
        chown -R www-data:www-data /var/www/html
        echo "- Setting file permissions..."
        chmod 775 index.php
        echo "✅ Adminer downloaded and configured successfully"
    else
        echo "❌ ERROR: Failed to download Adminer!"
        exit 1
    fi
else
    echo "✅ Adminer already installed"
fi

echo "2. Configuring Apache server..."
echo "- Setting global server name..."
echo "ServerName localhost" >> /etc/apache2/httpd.conf

echo "3. Creating virtual host configuration..."
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
echo "✅ Virtual host configuration created"

echo "4. Configuring Apache modules and settings..."
echo "- Updating Apache configuration..."

echo "Listen 8080" > /etc/apache2/conf.d/port.conf

if ! sed -i \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/User apache/User www-data/' \
    -e 's/Group apache/Group www-data/' \
    /etc/apache2/httpd.conf; then
    echo "❌ ERROR: Failed to configure Apache!"
    exit 1
fi

echo "- Testing configuration..."
httpd -t

echo "✅ Apache configuration updated"

echo "5. Configuring PHP..."
echo "- Enabling required PHP extensions..."
if ! sed -i \
    -e 's/;extension=pdo_mysql/extension=pdo_mysql/' \
    -e 's/;extension=mysqli/extension=mysqli/' \
    /etc/php82/php.ini; then
    echo "❌ ERROR: Failed to configure PHP!"
    exit 1
fi
echo "✅ PHP configuration updated"

echo "6. Setting up permissions..."
echo "- Setting ownership for Apache directories..."
chown -R www-data:www-data /run/apache2 /var/www/html /var/log/apache2
echo "✅ Permissions set correctly"

echo "7. Creating healthcheck symlink..."
ln -sf /var/www/html/index.php /var/www/html/adminer.php
echo "✅ Healthcheck symlink created"

echo "8. Verifying configuration..."
if [ ! -f "/etc/apache2/conf.d/adminer.conf" ]; then
    echo "❌ ERROR: Virtual host configuration not found!"
    exit 1
fi
if [ ! -f "/var/www/html/index.php" ]; then
    echo "❌ ERROR: Adminer not installed correctly!"
    exit 1
fi
echo "✅ All configurations verified"

echo "=== Initialization complete. Starting Apache... ==="

cat << "EOF"

   _____       .___      .__                     
  /  _  \    __| _/_____ |__| ____   ___________ 
 /  /_\  \  / __ |/     \|  |/    \_/ __ \_  __ \
/    |    \/ /_/ |  Y Y  \  |   |  \  ___/|  | \/
\____|__  /\____ |__|_|  /__|___|  /\___  >__|   
        \/      \/     \/        \/     \/       

EOF

# Start Apache in foreground
exec httpd -D FOREGROUND