#!/bin/bash
set -e

# Path to the WordPress configuration file
CONFIG_FILE=/var/www/html/wp-config.php

# Only create wp-config.php if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Generating wp-config.php..."
    
    cat > "$CONFIG_FILE" << EOF
<?php
define( 'DB_NAME', '${MYSQL_DATABASE}' );
define( 'DB_USER', '${MYSQL_USER}' );
define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );
define( 'DB_HOST', '${MYSQL_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         '$(openssl rand -base64 48)' );
define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 48)' );
define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 48)' );
define( 'NONCE_KEY',        '$(openssl rand -base64 48)' );
define( 'AUTH_SALT',        '$(openssl rand -base64 48)' );
define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 48)' );
define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 48)' );
define( 'NONCE_SALT',       '$(openssl rand -base64 48)' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

/* Redis configuration */
define( 'WP_REDIS_HOST', '${REDIS_HOST}' );
define( 'WP_REDIS_PORT', ${REDIS_PORT} );
define( 'WP_REDIS_TIMEOUT', 1 );
define( 'WP_REDIS_READ_TIMEOUT', 1 );
define( 'WP_REDIS_DATABASE', 0 );

/* FTP configuration */
define('FTP_USER', '${FTP_USER}');
define('FTP_PASS', '${FTP_PASS}');
define('FTP_HOST', 'ftp:21');  // Or use the IP address of the FTP container

/* That's all, stop editing! Happy publishing. */

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

    # Adjust file permissions
    chown www-data:www-data "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    
    echo "wp-config.php has been generated successfully!"
fi

#initialize wordpress
exec /usr/local/bin/init-wordpress.sh