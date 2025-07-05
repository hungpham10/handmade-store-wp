FROM php:8.1-fpm

WORKDIR /app

ARG WORDPRESS_VERSION=6.8.1
ARG REDIS_CACHE_VERSION=2.5.4
ARG WOOCOMMERCE_VERSION=9.9.5

RUN apt-get update && apt-get install -y 										\
    libpng-dev 														\
    libjpeg-dev 													\
    libfreetype6-dev 													\
    libzip-dev 														\
    unzip 														\
    mariadb-client 													\
    ca-certificates 													\
    nginx 														\
    curl 														\
    screen 														\
    supervisor 	 													\
    gettext-base													\
    && docker-php-ext-configure gd --with-freetype --with-jpeg 								\
    && docker-php-ext-install gd pdo pdo_mysql zip mysqli 								\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup Wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz 				\
    && tar -xzf wordpress.tar.gz -C /var/www/html --strip-components=1 							\
    && rm wordpress.tar.gz 												\
    && chown -R www-data:www-data /var/www/html

# Setup Woocommerce
RUN curl -o /tmp/woocommerce.zip -SL https://downloads.wordpress.org/plugin/woocommerce.${WOOCOMMERCE_VERSION}.zip 	\
    && unzip /tmp/woocommerce.zip -d /var/www/html/wp-content/plugins/ 							\
    && rm /tmp/woocommerce.zip 												\
    && chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce

# Setup Redis Object Cache
RUN curl -o /tmp/redis-cache.zip -SL https://downloads.wordpress.org/plugin/redis-cache.${REDIS_CACHE_VERSION}.zip 	\
    && unzip /tmp/redis-cache.zip -d /var/www/html/wp-content/plugins/ 							\
    && rm /tmp/redis-cache.zip 												\
    && chown -R www-data:www-data /var/www/html/wp-content/plugins/redis-cache

# Create supervisor configuration directory
RUN mkdir -p /etc/supervisor/conf.d
RUN rm -fr /usr/local/etc/php-fpm.d/*
RUN which /usr/bin/supervisord

# Copy supervisor configuration files
COPY sql/*.sql /app/sql/
COPY conf/nginx/*.conf /etc/nginx/conf.d/
COPY conf/php/*.ini /usr/local/etc/php/
COPY conf/php/*.conf /usr/local/etc/php-fpm.d/
COPY conf/supervisor/*.conf /etc/supervisor/
COPY conf/wordpress/*.php /var/www/html/
COPY scripts/release.sh /app/endpoint.sh

RUN mkdir -p /var/log/nginx && 												\
    chown -R www-data:www-data /var/log/nginx && 									\
    chmod -R 755 /var/www/html

ENTRYPOINT ["/app/endpoint.sh", "/usr/bin/supervisord", "/sql"]
EXPOSE 8080
