FROM alpine:3.19

# Add necessary repositories and install Grafana
RUN apk update && apk add --no-cache \
    grafana \
    bash \
    curl \
    libc6-compat

# Create necessary directories with correct permissions
RUN mkdir -p /etc/grafana/provisioning/datasources \
    /etc/grafana/provisioning/dashboards \
    /var/lib/grafana \
    /var/lib/grafana/dashboards

# Set correct permissions
RUN chown -R grafana:grafana /var/lib/grafana /etc/grafana

# Copy configuration files
COPY --chown=grafana:grafana ./conf/grafana.ini /etc/grafana/
COPY --chown=grafana:grafana ./conf/provisioning/datasources/prometheus.yml /etc/grafana/provisioning/datasources/
COPY --chown=grafana:grafana ./conf/provisioning/dashboards/dashboard.yml /etc/grafana/provisioning/dashboards/
COPY --chown=grafana:grafana ./dashboards/alien_eggs.json /var/lib/grafana/dashboards/

# Environment variables
ENV GF_PATHS_CONFIG=/etc/grafana/grafana.ini \
    GF_PATHS_DATA=/var/lib/grafana \
    GF_PATHS_LOGS=/var/log/grafana

# Expose the Grafana port
EXPOSE 3000

# Switch to grafana user
USER grafana

# Start Grafana
CMD ["grafana-server", \
     "--config=/etc/grafana/grafana.ini", \
     "--homepath=/usr/share/grafana"]