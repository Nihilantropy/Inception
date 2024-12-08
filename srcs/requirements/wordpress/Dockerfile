# Base image
FROM alpine:3.19

# Install dependencies and utilities
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
    php81-phar \
    mariadb-client \
    curl \
    bash \
    && ln -s /usr/bin/php81 /usr/bin/php

# Create the www-data user and add it to the existing www-data group
RUN adduser -S -G www-data www-data

# Add an all the tools scripts

COPY ./tools/init-wp-config.sh /usr/local/bin/init-wp-config.sh 
COPY ./tools/init-wordpress.sh /usr/local/bin/init-wordpress.sh 
COPY ./tools/setup_db.sh /usr/local/bin/setup_db.sh

# Ensure scripts are executable
RUN chmod +x /usr/local/bin/init-wp-config.sh && \
	chmod +x /usr/local/bin/init-wordpress.sh && \
	chmod +x /usr/local/bin/setup_db.sh

# Expose the PHP-FPM port
EXPOSE 9000

# Set the entrypoint for the container
ENTRYPOINT ["/usr/local/bin/init-wp-config.sh"]
