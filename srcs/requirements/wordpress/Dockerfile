# Base image
FROM alpine:3.19

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
	php81-opcache \
    mariadb-client \
    curl

# Configure PHP-FPM
RUN mkdir -p /run/php && \
    sed -i 's|^;daemonize = yes|daemonize = no|' /etc/php81/php-fpm.conf && \
    sed -i 's|^listen = 127.0.0.1:9000|listen = /run/php/php-fpm.sock|' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's|^;listen.owner = nobody|listen.owner = nobody|' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's|^;listen.group = nobody|listen.group = nogroup|' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's|^;listen.mode = 0660|listen.mode = 0660|' /etc/php81/php-fpm.d/www.conf

EXPOSE 9000

# Add an entrypoint script
COPY ./tools/* /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/setup_db.sh
ENTRYPOINT ["entrypoint.sh"]
