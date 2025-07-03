<?php
define('DB_NAME', '%%DB_NAME%%');
define('DB_USER', '%%DB_USER%%');
define('DB_PASSWORD', '%%DB_PASSWORD%%');
define('DB_HOST', '%%DB_HOST%%');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY', '%%AUTH_KEY%%');
define('SECURE_AUTH_KEY', '%%SECURE_AUTH_KEY%%');
define('LOGGED_IN_KEY', '%%LOGGED_IN_KEY%%');
define('NONCE_KEY', '%%NONCE_KEY%%');
define('AUTH_SALT', '%%AUTH_SALT%%');
define('SECURE_AUTH_SALT', '%%SECURE_AUTH_SALT%%');
define('LOGGED_IN_SALT', '%%LOGGED_IN_SALT%%');
define('NONCE_SALT', '%%NONCE_SALT%%');

$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

