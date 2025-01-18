FROM alpine:3.19

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
        vsftpd \
        openssl \
        shadow \
        linux-pam \
        bash \
        netcat-openbsd \
        logrotate && \
    rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /var/log && \
    mkdir -p /etc/vsftpd && \
    mkdir -p /var/run/vsftpd && \
    mkdir -p /etc/ssl/private

# Configure logrotate for vsftpd logs
COPY <<EOF /etc/logrotate.d/vsftpd
/var/log/vsftpd.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    create 644 root root
}
EOF

# Copy the init script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

WORKDIR /var/www/html

# Expose FTP ports
EXPOSE 20 21 21100-21110

ENTRYPOINT ["/init.sh"]