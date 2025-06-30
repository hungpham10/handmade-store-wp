-- Set up initial site settings
INSERT INTO wp_options (option_name, option_value, autoload) VALUES
('blogname', 'My WordPress Site', 'yes'),
('blogdescription', 'A pre-configured WordPress site', 'yes'),
('siteurl', 'http://localhost:8080', 'yes'),
('home', 'http://localhost:8080', 'yes'),
('admin_email', 'admin@localhost', 'yes');

-- Create an admin user
INSERT INTO wp_users (user_login, user_pass, user_nicename, user_email, user_registered, user_status, display_name) VALUES
('admin', MD5('admin_password'), 'admin', 'admin@localhost', NOW(), 0, 'Admin');

-- Assign admin role
INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES
((SELECT ID FROM wp_users WHERE user_login = 'admin'), 'wp_capabilities', 'a:1:{s:13:"administrator";b:1;}'),
((SELECT ID FROM wp_users WHERE user_login = 'admin'), 'wp_user_level', '10');
