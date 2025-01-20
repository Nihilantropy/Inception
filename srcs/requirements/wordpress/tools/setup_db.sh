#!/bin/bash
set -e

echo "=== Starting WordPress Database Setup ==="

echo "1. Verifying environment variables..."
required_vars="WORDPRESS_DB_HOST MYSQL_PORT MYSQL_USER MYSQL_PASSWORD WORDPRESS_DB_NAME"
for var in $required_vars; do
    if [ -z "${!var}" ]; then
        echo "❌ ERROR: Required environment variable $var is not set!"
        exit 1
    fi
done
echo "✅ Environment variables verified"

echo "2. Waiting for MariaDB connection..."
attempt=1
max_attempts=30
until mysqladmin ping -h "$WORDPRESS_DB_HOST" -P "$MYSQL_PORT" --silent; do
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ ERROR: Could not connect to MariaDB after $max_attempts attempts!"
        exit 1
    fi
    echo "- Attempt $attempt/$max_attempts: MariaDB is not ready yet. Retrying in 2 seconds..."
    attempt=$((attempt + 1))
    sleep 2
done
echo "✅ MariaDB connection established"

echo "3. Creating WordPress users table..."
mysql -h "$WORDPRESS_DB_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$WORDPRESS_DB_NAME" <<EOSQL
CREATE TABLE IF NOT EXISTS wp_users (
  ID bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  user_login varchar(60) NOT NULL DEFAULT '',
  user_pass varchar(255) NOT NULL DEFAULT '',
  user_nicename varchar(50) NOT NULL DEFAULT '',
  user_email varchar(100) NOT NULL DEFAULT '',
  user_url varchar(100) NOT NULL DEFAULT '',
  user_registered datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_activation_key varchar(255) NOT NULL DEFAULT '',
  user_status int(11) NOT NULL DEFAULT '0',
  display_name varchar(250) NOT NULL DEFAULT '',
  PRIMARY KEY (ID),
  KEY user_login_key (user_login),
  KEY user_nicename (user_nicename),
  KEY user_email (user_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOSQL

if [ $? -eq 0 ]; then
    echo "✅ WordPress users table created/verified successfully"
else
    echo "❌ ERROR: Failed to create WordPress users table!"
    exit 1
fi

echo "4. Creating default WordPress users..."
mysql -h "$WORDPRESS_DB_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$WORDPRESS_DB_NAME" <<EOSQL
INSERT INTO wp_users (user_login, user_pass, user_email, user_registered, display_name)
SELECT 'editor_user', MD5('securepassword'), 'editor@example.com', NOW(), 'Editor'
WHERE NOT EXISTS (SELECT 1 FROM wp_users WHERE user_login = 'editor_user');

INSERT INTO wp_users (user_login, user_pass, user_email, user_registered, display_name)
SELECT 'non_admin', MD5('securepassword'), 'nonadmin@example.com', NOW(), 'Non Admin'
WHERE NOT EXISTS (SELECT 1 FROM wp_users WHERE user_login = 'non_admin');
EOSQL

if [ $? -eq 0 ]; then
    echo "✅ Default users created successfully"
else
    echo "❌ ERROR: Failed to create default users!"
    exit 1
fi

echo "5. Verifying database setup..."
user_count=$(mysql -h "$WORDPRESS_DB_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$WORDPRESS_DB_NAME" -N -e "SELECT COUNT(*) FROM wp_users;")
if [ "$user_count" -gt 0 ]; then
    echo "✅ Database verification successful"
else
    echo "❌ ERROR: Database verification failed!"
    exit 1
fi

echo "=== Database setup complete. Starting PHP-FPM... ==="


cat << "EOF"

██╗    ██╗ ██████╗ ██████╗ ██████╗ ██████╗ ██████╗ ███████╗███████╗███████╗
██║    ██║██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝
██║ █╗ ██║██║   ██║██████╔╝██║  ██║██████╔╝██████╔╝█████╗  ███████╗███████╗
██║███╗██║██║   ██║██╔══██╗██║  ██║██╔═══╝ ██╔══██╗██╔══╝  ╚════██║╚════██║
╚███╔███╔╝╚██████╔╝██║  ██║██████╔╝██║     ██║  ██║███████╗███████║███████║
 ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝

EOF

# Start PHP-FPM
php-fpm82 -F
