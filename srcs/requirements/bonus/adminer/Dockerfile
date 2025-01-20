FROM alpine:3.20

# Install required packages
RUN apk update && apk add --no-cache \
    apache2 \
    php82 \
    php82-apache2 \
    php82-curl \
    php82-cli \
    php82-mysqli \
    php82-gd \
    php82-session \
    php82-pdo \
    php82-pdo_mysql \
    php82-json \
    php82-mbstring \
    mariadb-client \
    wget

# Create www-data user if it doesn't exist
RUN addgroup -S -g 82 www-data 2>/dev/null || true && \
    adduser -S -u 82 -D -H -h /var/www -G www-data -g www-data www-data 2>/dev/null || true

# Create necessary directories
RUN mkdir -p /var/www/html \
    && mkdir -p /run/apache2

# Copy initialization script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 8080

# Start using initialization script
ENTRYPOINT ["/init.sh"]