FROM alpine:3.19

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

# Create cAdvisor user and add to docker group
RUN addgroup -S cadvisor && \
    adduser -S -G cadvisor cadvisor && \
    addgroup -S docker && \
    adduser cadvisor docker

# Download and install cAdvisor binary
RUN wget -O /usr/local/bin/cadvisor "https://github.com/google/cadvisor/releases/download/${VERSION}/cadvisor-${VERSION}-linux-amd64" && \
    chmod +x /usr/local/bin/cadvisor

# Copy initialization script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# Expose cAdvisor port
EXPOSE 8080

# Switch to non-root user
USER cadvisor

# Start using initialization script
ENTRYPOINT ["/init.sh"]