# Base image
FROM alpine:3.19

# Set environment variables
ENV WORDPRESS_VERSION=6.4 \
    WORDPRESS_PATH=/var/www/html

# Install dependencies
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-curl \
    php81-json \
    php81-zip \
    php81-gd \
    php81-mbstring \
    php81-xml \
    php81-session \
    mariadb-client \
    curl \
    tar \
    && mkdir -p $WORDPRESS_PATH

# Download and configure WordPress
RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    mv /tmp/wordpress/* $WORDPRESS_PATH && \
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz && \
    chown -R nobody:nogroup $WORDPRESS_PATH

# Configure PHP-FPM
RUN mkdir -p /run/php && \
    sed -i 's|^;daemonize = yes|daemonize = no|' /etc/php81/php-fpm.conf && \
    sed -i 's|^listen = 127.0.0.1:9000|listen = /run/php/php-fpm.sock|' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's|^;listen.owner = nobody|listen.owner = nobody|' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's|^;listen.group = nobody|listen.group = nogroup|' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's|^;listen.mode = 0660|listen.mode = 0660|' /etc/php81/php-fpm.d/www.conf

# Expose PHP-FPM socket
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm81", "-F"]
