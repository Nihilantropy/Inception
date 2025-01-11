# Base image
FROM alpine:3.19

# Install necessary packages
RUN apk add --no-cache \
    wget \
    tar \
    openssl \
    python3 \
    py3-bcrypt \
    shadow

# Create prometheus user and group first
RUN addgroup -S prometheus && \
    adduser -S -G prometheus -s /sbin/nologin prometheus

# Set up Prometheus
WORKDIR /prometheus
RUN wget https://github.com/prometheus/prometheus/releases/download/v3.0.1/prometheus-3.0.1.linux-amd64.tar.gz && \
    tar -xvzf prometheus-3.0.1.linux-amd64.tar.gz && \
    mv prometheus-3.0.1.linux-amd64/* . && \
    rm -rf prometheus-3.0.1.linux-amd64 prometheus-3.0.1.linux-amd64.tar.gz

# Create necessary directories
RUN mkdir -p /etc/prometheus \
    /prometheus/data \
    /etc/prometheus/certs

# Set permissions
RUN chown -R prometheus:prometheus /etc/prometheus && \
    chown -R prometheus:prometheus /prometheus && \
    chmod -R 775 /prometheus/data && \
    chmod g+rwx /prometheus/data && \
    chmod +x /prometheus/prometheus  # Ensure prometheus binary is executable

# Copy the configuration files
COPY --chown=prometheus:prometheus ./conf/prometheus.yml /etc/prometheus/

# Copy the initialization script
COPY --chown=root:root ./tools/init.sh /init.sh
RUN chmod +x /init.sh

# Expose Prometheus port
EXPOSE 9090

# Switch to prometheus user
USER prometheus
WORKDIR /prometheus

# Start using the initialization script
ENTRYPOINT ["/init.sh"]