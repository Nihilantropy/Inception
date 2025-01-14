#!/bin/sh
set -e

echo "=== Starting Grafana Initialization ==="

echo "1. Creating necessary directories..."
mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards
mkdir -p /var/lib/grafana/dashboards
mkdir -p /var/log/grafana
echo "✅ Directories created successfully"

echo "2. Generating grafana.ini configuration..."
cat > /etc/grafana/grafana.ini << EOF
[paths]
data = /var/lib/grafana
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins
provisioning = /etc/grafana/provisioning

[server]
protocol = http
http_addr = 0.0.0.0
http_port = 3000
domain = ${DOMAIN_NAME}
root_url = https://${DOMAIN_NAME}/grafana/
serve_from_sub_path = true

[security]
admin_user = ${GF_SECURITY_ADMIN_USER}
admin_password = ${GF_SECURITY_ADMIN_PASSWORD}
allow_embedding = true
cookie_secure = true
disable_gravatar = true

[auth]
disable_login_form = false
disable_signout_menu = true

[auth.anonymous]
enabled = false

[dashboards]
min_refresh_interval = 5s

[users]
default_theme = dark
EOF
echo "✅ grafana.ini created successfully at /etc/grafana/grafana.ini"

echo "3. Generating Prometheus datasource configuration..."
cat > /etc/grafana/provisioning/datasources/prometheus.yml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    version: 1
    editable: true
    basicAuth: true
    basicAuthUser: admin
    secureJsonData:
      basicAuthPassword: ${PROMETHEUS_PASSWORD}
    jsonData:
      timeInterval: "5s"
      tlsSkipVerify: true
EOF
echo "✅ Prometheus datasource configuration created successfully"

echo "4. Generating dashboard provisioning configuration..."
cat > /etc/grafana/provisioning/dashboards/dashboard.yml << EOF
apiVersion: 1

providers:
  - name: 'AlienEggs'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
      foldersFromFilesStructure: true
EOF
echo "✅ Dashboard provisioning configuration created successfully"

echo "5. Setting correct permissions..."
chown -R grafana:grafana /etc/grafana /var/lib/grafana /var/log/grafana
echo "✅ Permissions set correctly"

echo "6. Verifying configurations..."
if [ ! -f "/etc/grafana/grafana.ini" ]; then
    echo "❌ ERROR: grafana.ini not found!"
    exit 1
fi
if [ ! -f "/etc/grafana/provisioning/datasources/prometheus.yml" ]; then
    echo "❌ ERROR: prometheus.yml not found!"
    exit 1
fi
if [ ! -f "/etc/grafana/provisioning/dashboards/dashboard.yml" ]; then
    echo "❌ ERROR: dashboard.yml not found!"
    exit 1
fi
echo "✅ All configuration files verified"

echo "=== Initialization complete. Starting Grafana... ==="

# Start Grafana
exec grafana-server \
    --homepath=/usr/share/grafana \
    --config=/etc/grafana/grafana.ini