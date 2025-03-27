FROM alpine:3.20

ENV VERSION="v0.49.2"

# Install necessary packages
RUN apk update && apk add --no-cache \
    wget \
    curl \
    shadow \
    libc6-compat \
    device-mapper \
    thin-provisioning-tools \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Create cAdvisor user and add to docker group with proper GID
RUN addgroup -S -g 998 docker && \
    addgroup -S cadvisor && \
    adduser -S -G cadvisor cadvisor && \
    adduser cadvisor docker

# Create necessary directories and files with proper permissions
RUN mkdir -p /etc/cadvisor && \
    touch /etc/machine-id && \
    chmod 644 /etc/machine-id && \
    chown -R cadvisor:cadvisor /etc/cadvisor && \
    mkdir -p /var/run/docker && \
    chown -R root:docker /var/run/docker && \
    chmod 775 /var/run/docker

# Download and install cAdvisor binary
RUN wget -O /usr/local/bin/cadvisor "https://github.com/google/cadvisor/releases/download/${VERSION}/cadvisor-${VERSION}-linux-amd64" && \
    chmod +x /usr/local/bin/cadvisor && \
    chown root:docker /usr/local/bin/cadvisor

# Copy initialization script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh && \
    chown root:docker /init.sh

# Expose cAdvisor port
EXPOSE 8080

# Run as root
USER root

ENTRYPOINT ["/init.sh"]
