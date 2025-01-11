FROM alpine:3.19

# Install required packages with correct Alpine package names
RUN apk update && apk add --no-cache \
    apache2 \
    php81 \
    php81-apache2 \
    php81-curl \
    php81-cli \
    php81-mysqli \
    php81-gd \
    php81-session \
    mariadb \
    wget

# Create www-data user if it doesn't exist (Alpine may have it already)
RUN addgroup -S -g 82 www-data 2>/dev/null || true && \
    adduser -S -u 82 -D -H -h /var/www -G www-data -g www-data www-data 2>/dev/null || true

# Create necessary directories
RUN mkdir -p /var/www/html

# Download and set up Adminer
RUN cd /var/www/html && \
    wget "http://www.adminer.org/latest.php" -O adminer.php && \
    chown -R www-data:www-data /var/www/html && \
    chmod 755 adminer.php && \
    rm -f index.html

# Configure Apache
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/Listen 80/Listen 8080/' /etc/apache2/httpd.conf && \
    sed -i 's/User apache/User www-data/' /etc/apache2/httpd.conf && \
    sed -i 's/Group apache/Group www-data/' /etc/apache2/httpd.conf

# Create directory for Apache to store PID file and set permissions
RUN mkdir -p /run/apache2 && \
    chown -R www-data:www-data /run/apache2 /var/www/html /var/log/apache2

EXPOSE 8080

# Start Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]