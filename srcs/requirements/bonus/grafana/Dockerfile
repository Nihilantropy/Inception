FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache bash curl libc6-compat

# Download Grafana
ARG GRAFANA_VERSION=11.4.0
RUN curl -fsSL https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz | tar -zx && \
    mv grafana-${GRAFANA_VERSION} /usr/share/grafana

# Create necessary directories
RUN mkdir -p /etc/grafana /var/lib/grafana && \
    adduser -S grafana && \
    chown -R grafana:grafana /usr/share/grafana /etc/grafana /var/lib/grafana

# Set environment variables
ENV GF_PATHS_CONFIG=/etc/grafana/grafana.ini \
    GF_PATHS_DATA=/var/lib/grafana \
    GF_PATHS_HOME=/usr/share/grafana \
    GF_PATHS_LOGS=/var/lib/grafana/logs

COPY ./conf/prometheus.yml /usr/share/grafana/conf/provisioning

# Expose the default Grafana port
EXPOSE 3000

# Set up entry point
WORKDIR /usr/share/grafana
USER grafana
ENTRYPOINT ["./bin/grafana-server", "--config=/etc/grafana/grafana.ini", "--homepath=/usr/share/grafana"]
