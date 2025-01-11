FROM alpine:3.19

# Install necessary utilities
RUN apk update && \
    apk add --no-cache \
        vsftpd \
        openrc \
        shadow \
        bash

# Copy the init script into the container
COPY /tools/init.sh /usr/local/bin/init.sh

# Make the script executable
RUN chmod +x /usr/local/bin/init.sh

# Expose FTP port
EXPOSE 21

# Entry point to run the init script and start vsftpd
CMD ["init.sh"]
