#!/bin/sh
set -e

# Ensure wp-config.php is configured
if [ ! -f "$WORDPRESS_PATH/wp-config.php" ]; then
  cp $WORDPRESS_PATH/wp-config-sample.php $WORDPRESS_PATH/wp-config.php
  sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" $WORDPRESS_PATH/wp-config.php
  sed -i "s/username_here/$WORDPRESS_DB_USER/" $WORDPRESS_PATH/wp-config.php
  sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" $WORDPRESS_PATH/wp-config.php
  sed -i "s/localhost/$WORDPRESS_DB_HOST/" $WORDPRESS_PATH/wp-config.php
fi

# Wait for the database to be ready
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h "$WORDPRESS_DB_HOST" --silent; do
  sleep 2
done

# Ensure required WordPress database users are created
echo "Creating required WordPress users..."
mysql -h "$WORDPRESS_DB_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$WORDPRESS_DB_NAME" <<EOSQL
INSERT INTO wp_users (user_login, user_pass, user_email, user_registered, display_name)
SELECT 'editor_user', MD5('securepassword'), 'editor@example.com', NOW(), 'Editor'
WHERE NOT EXISTS (SELECT 1 FROM wp_users WHERE user_login = 'editor_user');
INSERT INTO wp_users (user_login, user_pass, user_email, user_registered, display_name)
SELECT 'non_admin', MD5('securepassword'), 'nonadmin@example.com', NOW(), 'Non Admin'
WHERE NOT EXISTS (SELECT 1 FROM wp_users WHERE user_login = 'non_admin');
EOSQL

exec "$@"
