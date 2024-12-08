#!/bin/bash

# Path to the WordPress configuration file
CONFIG_FILE=/var/www/html/wp-config.php

# Create wp-config.php with the necessary content
cat << EOF > $CONFIG_FILE
<?php
/**
 * The base configuration for WordPress
 */

// ** MySQL settings ** //
define( 'DB_NAME', '${MYSQL_DATABASE}' );
define( 'DB_USER', '${MYSQL_USER}' );
define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );
define( 'DB_HOST', '${MYSQL_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'WP_ALLOW_REPAIR', true );

// ** Authentication Unique Keys and Salts ** //
define('AUTH_KEY',         'pa50+@-VFB1#\`KfI@fU[ay15nKrWUAZQzf+ [p_Z6*D95<tl.0\$Vbv0 ;Ce}[GS!');
define('SECURE_AUTH_KEY',  '?1HLb0,\$aIr=M?}W]elB=L-Se-Jj11KN3/y0}HA|2^z@d@; K+5#@c&#Sn_u s\$Y');
define('LOGGED_IN_KEY',    '>Ev-^/MU<eFz6TgW7GpgKp. FwkBXp<80ADlFl!n_FWz.I\$DA+Nnxb](x88zb4+w');
define('NONCE_KEY',        'H5^ZM*>*e]Xb=#8+:X%v+[9e)HiK1Qy|?\$:bI(XHxB3}%8_-Bz)fJKs\`fx\$qxo@g');
define('AUTH_SALT',        'Iwch[_,*}~j}r9 E{[g{>(j*6]ZwOn:?rCcrJI-^|z6S}[@1TXEQ^%Woy5+1{hEJ');
define('SECURE_AUTH_SALT', '@+%&M}|M;!wqY*tYDj*Ir[Fr}):7gaqUhWTbO2O)X(^|7uhz^{:\$k~4<05*a~ZTw');
define('LOGGED_IN_SALT',   '1&L JcIJoap_u-<5xd8Z+K\$t{}bU{wibush*Y?rv?:MT|7xg uyH34|Om>LbFKOQ');
define('NONCE_SALT',       'ER #1e-@R7P@vY,lfL+[4o7gSW9SFx+iXSsCz]RlP0e/KT4JFXJrsAt(qp{rJ@6\`');

define( 'WP_REDIS_HOST', '${REDIS_HOST}' );
define( 'WP_REDIS_PORT', '${REDIS_PORT}' );

define('WP_CACHE', true);

// ** Database Table prefix ** //
\$table_prefix = 'wp_';

// ** Debugging settings ** //
define( 'WP_DEBUG', true );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

# Adjust file permissions
chown www-data:www-data $CONFIG_FILE
chmod 644 $CONFIG_FILE

echo "wp-config.php has been generated successfully!"

cat /var/www/html/wp-config.php

exec /usr/local/bin/init-wordpress.sh
