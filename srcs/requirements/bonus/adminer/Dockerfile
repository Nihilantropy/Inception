FROM alpine:3.19

# Install required packages
RUN apk update && apk add --no-cache \
    apache2 \
    php81 \
    php81-apache2 \
    php81-curl \
    php81-cli \
    php81-mysqli \
    php81-gd \
    php81-session \
    php81-pdo \
    php81-pdo_mysql \
    php81-json \
    php81-mbstring \
    mariadb-client \
    wget

# Create www-data user if it doesn't exist
RUN addgroup -S -g 82 www-data 2>/dev/null || true && \
    adduser -S -u 82 -D -H -h /var/www -G www-data -g www-data www-data 2>/dev/null || true

# Create necessary directories
RUN mkdir -p /var/www/html \
    && mkdir -p /run/apache2

# Copy initialization script
COPY tools/init.sh /usr/local/bin/
RUN chmod +x /init.sh

EXPOSE 8080

# Start using initialization script
CMD ["/init.sh"]