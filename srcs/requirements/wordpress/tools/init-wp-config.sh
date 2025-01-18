#!/bin/bash
set -e

echo "=== Starting WordPress Configuration ==="

CONFIG_FILE=/var/www/html/wp-config.php

if [ ! -f "$CONFIG_FILE" ]; then
    echo "1. Preparing WordPress configuration..."
    echo "- Checking environment variables..."
    # Check required environment variables
    required_vars="MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD MYSQL_HOST FTP_USER FTP_PASS"
    for var in $required_vars; do
        if [ -z "${!var}" ]; then
            echo "❌ ERROR: Required environment variable $var is not set!"
            exit 1
        fi
    done
    echo "✅ Environment variables verified"
    
    echo "2. Fetching WordPress security keys..."
    KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    if [ -z "$KEYS" ]; then
        echo "❌ ERROR: Failed to fetch WordPress security keys!"
        exit 1
    fi
    echo "✅ Security keys generated successfully"
    
    echo "3. Generating wp-config.php..."
    cat > "$CONFIG_FILE" << EOF
<?php
/* Database configuration */
define( 'DB_NAME', '${MYSQL_DATABASE}' );
define( 'DB_USER', '${MYSQL_USER}' );
define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );
define( 'DB_HOST', '${MYSQL_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/* Authentication unique keys and salts */
${KEYS}

/* WordPress database table prefix */
\$table_prefix = 'wp_';

/* Debug settings */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );

/* Redis configuration */
define( 'WP_REDIS_HOST', '${REDIS_HOST}' );
define( 'WP_REDIS_PORT', ${REDIS_PORT} );
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
define('FS_METHOD', 'ftpsext');
define('FTP_BASE', '/var/www/html/');
define('FTP_CONTENT_DIR', '/var/www/html/wp-content/');
define('FTP_PLUGIN_DIR', '/var/www/html/wp-content/plugins/');
define('FTP_SSL', true);  // Enable SSL
define('FTP_VERIFY_SSL', false);  // Disable SSL verification for self-signed certificates

/* Absolute path to the WordPress directory */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/* Sets up WordPress vars and included files */
require_once ABSPATH . 'wp-settings.php';
EOF
    echo "✅ wp-config.php generated successfully"

    echo "4. Setting file permissions..."
    echo "- Setting ownership..."
    chown www-data:www-data "$CONFIG_FILE"
    echo "- Setting file mode..."
    chmod 644 "$CONFIG_FILE"
    echo "✅ Permissions set correctly"

    echo "5. Verifying configuration..."
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ ERROR: wp-config.php was not created!"
        exit 1
    fi
    if ! php -l "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "❌ ERROR: wp-config.php contains syntax errors!"
        exit 1
    fi
    echo "✅ Configuration file verified"
else
    echo "✅ WordPress configuration already exists"
fi

echo "=== Configuration complete. Initializing WordPress... ==="

# Initialize WordPress
exec /usr/local/bin/init-wordpress.sh