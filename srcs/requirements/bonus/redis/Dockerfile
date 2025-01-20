# Base image
FROM alpine:3.20

# Install Redis
RUN apk update && apk add --no-cache redis

# Copy the init script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# Expose Redis default port
EXPOSE 6379

# Start init.sh script
ENTRYPOINT ["/init.sh"]
