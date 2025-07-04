<?php

define('WP_HOME', '%%WP_HOME%%');
define('WP_SITEURL', '%%WP_SITEURL%%');
define('FORCE_SSL_ADMIN', %%FORCE_SSL_ADMIN%%);

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['REQUEST_SCHEME'] = "https";
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = %%HTTP_PORT%%;
}

define('DB_NAME', '%%DB_NAME%%');
define('DB_USER', '%%DB_USER%%');
define('DB_PASSWORD', '%%DB_PASSWORD%%');
define('DB_HOST', '%%DB_HOST%%');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('WP_REDIS_SCHEME', 'tcp');
define('WP_REDIS_HOST', '%%REDIS_HOST%%');
define('WP_REDIS_PORT', %%REDIS_PORT%%);
define('WP_REDIS_CLIENT', 'pecl');
define('WP_REDIS_TIMEOUT', %%REDIS_TIMEOUT%%);
define('WP_REDIS_READ_TIMEOUT', %%REDIS_TIMEOUT%%);
define('WP_REDIS_MAXTTL', %%REDIS_TTL%%);
define('WP_REDIS_SELECTIVE_FLUSH', true);
define('WP_CACHE', true);

define('AUTH_KEY', '%%AUTH_KEY%%');
define('SECURE_AUTH_KEY', '%%SECURE_AUTH_KEY%%');
define('LOGGED_IN_KEY', '%%LOGGED_IN_KEY%%');
define('NONCE_KEY', '%%NONCE_KEY%%');
define('AUTH_SALT', '%%AUTH_SALT%%');
define('SECURE_AUTH_SALT', '%%SECURE_AUTH_SALT%%');
define('LOGGED_IN_SALT', '%%LOGGED_IN_SALT%%');
define('NONCE_SALT', '%%NONCE_SALT%%');

$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

remove_action('template_redirect', 'redirect_canonical');
