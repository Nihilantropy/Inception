# Use Alpine Linux as the base image
FROM alpine:3.19

# Install vsftpd and tools
RUN apk update && \
    apk add --no-cache vsftpd bash openrc

# Create directories for FTP users
RUN mkdir -p /home/ftpusers && \
    mkdir -p /var/log/vsftpd && \
    adduser -h /home/ftpusers/ftpuser -D ftpuser && \
    echo "ftpuser:password" | chpasswd

# Set permissions for the shared volume
RUN chown -R ftpuser:ftpusers /var/www/html

# Copy the vsftpd configuration file
COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

# Expose ports for FTP
EXPOSE 20 21 21100-21110

# Start the vsftpd server
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]
