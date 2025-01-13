#!/bin/bash
set -e

# Path to the WordPress configuration file
CONFIG_FILE=/var/www/html/wp-config.php

# Only create wp-config.php if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Generating wp-config.php..."
    
    # Generate random keys using WordPress.org API
    KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    
    cat > "$CONFIG_FILE" << EOF
<?php
define( 'DB_NAME', '${MYSQL_DATABASE}' );
define( 'DB_USER', '${MYSQL_USER}' );
define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );
define( 'DB_HOST', '${MYSQL_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

${KEYS}

\$table_prefix = 'wp_';

define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );

/* Redis configuration */
define( 'WP_REDIS_HOST', 'redis' );
define( 'WP_REDIS_PORT', 6379 );
define( 'WP_REDIS_TIMEOUT', 1 );
define( 'WP_REDIS_READ_TIMEOUT', 1 );
define( 'WP_REDIS_DATABASE', 0 );
define( 'WP_CACHE', true );

define( 'WP_REDIS_DISABLE_METRICS', false );
define( 'WP_REDIS_METRICS_MAX_TIME', 60 );
define( 'WP_REDIS_SELECTIVE_FLUSH', true );
define( 'WP_REDIS_MAXTTL', 86400 );

/* FTP configuration */
define('FTP_USER', '${FTP_USER}');
define('FTP_PASS', '${FTP_PASS}');
define('FTP_HOST', 'ftp:21');
define('FS_METHOD', 'direct');
define('FTP_BASE', '/var/www/html/');
define('FTP_CONTENT_DIR', '/var/www/html/wp-content/');
define('FTP_PLUGIN_DIR', '/var/www/html/wp-content/plugins/');
define('FTP_SSL', false);

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

# Initialize wordpress
exec /usr/local/bin/init-wordpress.sh