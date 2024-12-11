# Use Alpine as the base image
FROM alpine:3.19

# Install necessary packages
RUN apk add --no-cache wget tar

# Set up Prometheus
WORKDIR /prometheus
RUN wget https://github.com/prometheus/prometheus/releases/download/v3.0.1/prometheus-3.0.1.linux-amd64.tar.gz && \
    tar -xvzf prometheus-3.0.1.linux-amd64.tar.gz && \
    mv prometheus-3.0.1.linux-amd64/* . && \
    rm -rf prometheus-3.0.1.linux-amd64 prometheus-3.0.1.linux-amd64.tar.gz

# Copy the configuration file
COPY ./conf/prometheus.yml /etc/prometheus/prometheus.yml

# Expose Prometheus port
EXPOSE 9090

# Start Prometheus
CMD ["./prometheus", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus/data"]
