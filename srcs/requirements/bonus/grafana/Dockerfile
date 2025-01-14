# Base image
FROM alpine:3.19

# Install necessary packages
RUN apk update && apk add --no-cache \
    grafana \
    bash \
    curl \
    wget \
    libc6-compat

# Create necessary base directories
RUN mkdir -p /etc/grafana \
    /var/lib/grafana \
    /var/log/grafana

# Copy the initialization script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# Copy the dashboard JSON
COPY dashboards/alien_eggs.json /var/lib/grafana/dashboards/

# Set permissions for grafana user
RUN chown -R grafana:grafana /etc/grafana /var/lib/grafana /var/log/grafana /init.sh

# Expose the Grafana port
EXPOSE 3000

# Switch to grafana user
USER grafana

# Start using initialization script
ENTRYPOINT ["/init.sh"]