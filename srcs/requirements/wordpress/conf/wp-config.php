<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', getenv('MYSQL_DATABASE') );

/** MySQL database username */
define( 'DB_USER', getenv('MYSQL_USER') );

/** MySQL database password */
define( 'DB_PASSWORD', getenv('MYSQL_PASSWORD') );

/** MySQL hostname */
define( 'DB_HOST', getenv('MYSQL_HOST') );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

define( 'WP_ALLOW_REPAIR', true );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'pa50+@-VFB1#`KfI@fU[ay15nKrWUAZQzf+ [p_Z6*D95<tl.0$Vbv0 ;Ce}[GS!');
define('SECURE_AUTH_KEY',  '?1HLb0,$aIr=M?}W]elB=L-Se-Jj11KN3/y0}HA|2^z@d@; K+5#@c&#Sn_u s$Y');
define('LOGGED_IN_KEY',    '>Ev-^/MU<eFz6TgW7GpgKp. FwkBXp<80ADlFl!n_FWz.I$DA+Nnxb](x88zb4+w');
define('NONCE_KEY',        'H5^ZM*>*e]Xb=#8+:X%v+[9e)HiK1Qy|?$:bI(XHxB3}%8_-Bz)fJKs`fx$qxo@g');
define('AUTH_SALT',        'Iwch[_,*}~j}r9 E{[g{>(j*6]ZwOn:?rCcrJI-^|z6S}[@1TXEQ^%Woy5+1{hEJ');
define('SECURE_AUTH_SALT', '@+%&M}|M;!wqY*tYDj*Ir[Fr}):7gaqUhWTbO2O)X(^|7uhz^{:$k~4<05*a~ZTw');
define('LOGGED_IN_SALT',   '1&L JcIJoap_u-<5xd8Z+K$t{}bU{wibush*Y?rv?:MT|7xg uyH34|Om>LbFKOQ');
define('NONCE_SALT',       'ER #1e-@R7P@vY,lfL+[4o7gSW9SFx+iXSsCz]RlP0e/KT4JFXJrsAt(qp{rJ@6`');

define( 'WP_REDIS_HOST', getenv('REDIS_HOST') );
define( 'WP_REDIS_PORT', getenv('REDIS_PORT') );     


define('WP_CACHE', true);

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', true );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
?>