FROM alpine:3.19

RUN apk update
RUN apk add \
    apache2 \
    php \
    libapache2-mod-php\
    php-curl \
    php-cli \
    php-mysql \
    php-gd \
    mariadb-server \
    wget

WORKDIR /var/www/html
RUN wget "http://www.adminer.org/latest.php" -O /var/www/html/adminer.php && \
    chown -R www-data:www-data /var/www/html/adminer.php && \
    chmod 755 -R /var/www/html/adminer.php && rm -rf index.html

EXPOSE 8080
    
RUN sed -i "s/Listen 80/Listen 8080/g" /etc/apache2/ports.conf
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]