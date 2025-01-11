FROM alpine:3.19

RUN apk add --no-cache \
		nginx \
		openssl \
		shadow

RUN mkdir -p /var/www/html && \
	chown -R nginx:www-data /var/www/html

RUN	usermod -aG www-data nginx

# Copy the initialization script
COPY --chown=nginx:nginx ./tools/init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]