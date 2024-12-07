#!/bin/sh
set -e

# Ensure wp-config.php is configured
if [ ! -f "$WORDPRESS_PATH/wp-config.php" ]; then
  echo "Configuring wp-config.php..."
  cp "$WORDPRESS_PATH/wp-config-sample.php" "$WORDPRESS_PATH/wp-config.php"
  sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" "$WORDPRESS_PATH/wp-config.php"
  sed -i "s/username_here/$WORDPRESS_DB_USER/" "$WORDPRESS_PATH/wp-config.php"
  sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" "$WORDPRESS_PATH/wp-config.php"
  sed -i "s/localhost/$WORDPRESS_DB_HOST/" "$WORDPRESS_PATH/wp-config.php"

  # Set DB_CHARSET and DB_COLLATE if needed
  sed -i "s/define('DB_CHARSET', 'utf8mb4');/define('DB_CHARSET', 'utf8');/" "$WORDPRESS_PATH/wp-config.php"
  sed -i "s/define('DB_COLLATE', '');/define('DB_COLLATE', 'utf8_general_ci');/" "$WORDPRESS_PATH/wp-config.php"
fi

# Wait for the database to be ready
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h "$WORDPRESS_DB_HOST" -P "$MYSQL_PORT" --silent; do
  echo "MariaDB is not ready yet. Retrying in 2 seconds..."
  sleep 2
done
echo "MariaDB is ready."

# Ensure WordPress database and wp_users table exist
echo "Ensuring wp_users table exists..."
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
echo "wp_users table is ready."

# Ensure required WordPress database users are created
echo "Creating required WordPress users..."
mysql -h "$WORDPRESS_DB_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$WORDPRESS_DB_NAME" <<EOSQL
INSERT INTO wp_users (user_login, user_pass, user_email, user_registered, display_name)
SELECT 'editor_user', MD5('securepassword'), 'editor@example.com', NOW(), 'Editor'
WHERE NOT EXISTS (SELECT 1 FROM wp_users WHERE user_login = 'editor_user');
INSERT INTO wp_users (user_login, user_pass, user_email, user_registered, display_name)
SELECT 'non_admin', MD5('securepassword'), 'nonadmin@example.com', NOW(), 'Non Admin'
WHERE NOT EXISTS (SELECT 1 FROM wp_users WHERE user_login = 'non_admin');
EOSQL

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm81 -F
