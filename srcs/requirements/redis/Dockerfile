# Base image
FROM alpine:3.19

# Install Redis
RUN apk update && apk add --no-cache redis && \
    # Configure Redis
    echo "maxmemory 256mb" >> /etc/redis.conf && \
    echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf && \
    sed -i 's/^bind 127.0.0.1/#bind 127.0.0.1/' /etc/redis.conf && \
    # Ensure data persistence
    mkdir -p /data && chown redis:redis /data

# Expose Redis default port
EXPOSE 6379

# Start Redis server
CMD ["redis-server", "/etc/redis.conf", "--protected-mode", "no"]
