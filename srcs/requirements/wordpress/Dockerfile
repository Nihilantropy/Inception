# Base image
FROM alpine:3.20

# Install dependencies and utilities
RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-curl \
    php82-json \
    php82-zip \
    php82-gd \
    php82-mbstring \
    php82-xml \
    php82-session \
    php82-opcache \
    php82-phar \
    php82-pecl-redis \
    php82-ctype \
	php82-ftp \ 
    mariadb-client \
    curl \
    bash \
    && ln -s /usr/bin/php82 /usr/bin/php

# Create the www-data user and add it to the existing www-data group
RUN adduser -S -G www-data www-data

# Copy all the necessary scripts
COPY ./tools/init-wp-config.sh /usr/local/bin/init-wp-config.sh
COPY ./tools/init-wordpress.sh /usr/local/bin/init-wordpress.sh
COPY ./tools/setup_db.sh /usr/local/bin/setup_db.sh

# Ensure scripts are executable and set proper ownership/permissions
RUN chmod +x /usr/local/bin/init-wp-config.sh && \
    chmod +x /usr/local/bin/init-wordpress.sh && \
    chmod +x /usr/local/bin/setup_db.sh && \
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose the PHP-FPM port
EXPOSE 9000

# Set the entrypoint for the container
ENTRYPOINT ["/usr/local/bin/init-wp-config.sh"]