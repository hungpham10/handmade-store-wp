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

define('LITESPEED_CONF', [
    'object' => [
        'enabled' => true,
        'host' => '%%REDIS_HOST%%',
	'port' => %%REDIS_PORT%%,
	'password' => '%%REDIS_PASSWORD%%',
        'default_lifetime' => %%REDIS_TTL%%,
        'persistent' => false,
    ],
]);
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

define( 'WP_DEBUG', true ); // Enable debug mode
define( 'WP_DEBUG_LOG', 'php://stderr' ); // Send WordPress debug logs to stderr
define( 'WP_DEBUG_DISPLAY', false ); // Prevent errors from displaying on the site
@ini_set( 'display_errors', 0 ); // Ensure errors are not displayed
@ini_set( 'log_errors', 1 ); // Enable PHP error logging
@ini_set( 'error_log', 'php://stderr' ); // Send all PHP errors to stderr
@ini_set( 'error_reporting', E_ALL | E_STRICT ); // Log all PHP errors, warnings, and notices

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

remove_action('template_redirect', 'redirect_canonical');
