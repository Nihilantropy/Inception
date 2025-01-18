#!/bin/sh
set -e

echo "=== Starting Grafana Initialization ==="

echo "1. Creating necessary directories..."
mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards
mkdir -p /etc/grafana/provisioning/plugins
mkdir -p /etc/grafana/provisioning/notifiers
mkdir -p /etc/grafana/provisioning/alerting
mkdir -p /var/lib/grafana/dashboards
mkdir -p /var/lib/grafana/plugins
mkdir -p /var/log/grafana
echo "✅ Directories created successfully"

# Clean up any existing lock files and sessions
rm -f /var/lib/grafana/.lock
rm -f /var/lib/grafana/sessions/*

echo "2. Generating grafana.ini configuration..."
cat > /etc/grafana/grafana.ini << EOF
#################################### Paths ####################################
[paths]

# Path to where grafana can store temp files, sessions, and the sqlite3 db
data = /var/lib/grafana

# Directory where grafana can store logs
logs = /var/log/grafana

# Directory where grafana will automatically scan and look for plugins
plugins = /var/lib/grafana/plugins

# Folder that contains provisioning config files
provisioning = /etc/grafana/provisioning

#################################### Server ####################################
[server]

# Protocol (http since we're behind Nginx that handles HTTPS)
protocol = http

# The ip address to bind to, we want to bind to all interfaces since we're in a container
http_addr = 0.0.0.0

# The http port to use - matching your docker-compose service port
http_port = 3000

# The public facing domain name used to access grafana from a browser
domain = ${DOMAIN_NAME}

# Redirect to correct domain if host header does not match domain
# Prevents DNS rebinding attacks
enforce_domain = true

# The full public facing url you use in browser, used for redirects and emails
# We're behind Nginx serving at /grafana subpath
root_url = %(protocol)s://%(domain)s/grafana

# Since we're serving from /grafana subpath, this needs to be true
serve_from_sub_path = true

# Enable logging of web requests for debugging
router_logging = true

# Enable gzip compression
enable_gzip = true

#################################### Security ####################################
[security]
# default admin user, created on startup
admin_user = ${GF_SECURITY_ADMIN_USER}

# default admin password, can be changed before first start of grafana
admin_password = ${GF_SECURITY_ADMIN_PASSWORD}

# Allow embedding Grafana dashboards
allow_embedding = true

# Set cookie secure flag for enhanced security
cookie_secure = true

# Set cookie SameSite attribute for better security
cookie_samesite = lax

# Disable gravatar to prevent unnecessary external calls
disable_gravatar = true

# Used for signing
secret_key = ${GF_SECURITY_SECRET_KEY}

#################################### Authentication ####################################
[auth]
# Allow standard login form
disable_login_form = false

# Keep the sign-out menu for users
disable_signout_menu = true

# Custom cookie name for better identification
login_cookie_name = grafana_session

#################################### Anonymous Access ####################################
[auth.anonymous]
# Disable anonymous access
enabled = false

#################################### Dashboards ####################################
[dashboards]
# Minimum dashboard refresh interval
min_refresh_interval = 5s

#################################### Users ####################################
[users]
# Theme preference
default_theme = dark

# Disable user signup
allow_sign_up = false

#################################### Session ####################################
[session]
# Session lifetime when user is active (default is 24h)
session_life_time = 24h

# Session lifetime when user is idle (default is 24h)
session_life_time_for_idle = 24h

#################################### Logging ####################################
[log]
# Either "console", "file", defaults to "console"
mode = console file

# Either "debug", "info", "warn", "error", "critical", default is "info"
level = info

# For "console" mode only
[log.console]
level = info
format = console

# For "file" mode only
[log.file]
level = info
format = text
EOF
echo "✅ Configuration file created successfully"

echo "3. Setting correct permissions..."
chown -R grafana:grafana /etc/grafana
chown -R grafana:grafana /var/lib/grafana
chown -R grafana:grafana /var/log/grafana
chmod -R 755 /etc/grafana/provisioning
chmod -R 755 /var/lib/grafana/dashboards
chmod -R 755 /var/lib/grafana/plugins

# Add example empty config files to prevent errors
touch /etc/grafana/provisioning/plugins/plugins.yaml
touch /etc/grafana/provisioning/notifiers/notifiers.yaml
touch /etc/grafana/provisioning/alerting/alerting.yaml
echo "✅ Permissions set successfully"

echo "4. Creating datasource configuration..."
cat > /etc/grafana/provisioning/datasources/prometheus.yml << EOF
apiVersion: 1

deleteDatasources:
  - name: Prometheus
    orgId: 1

datasources:
  - name: Prometheus
    type: prometheus
    uid: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    version: 1
    editable: true
    jsonData:
      timeInterval: "5s"
      queryTimeout: "30s"
      httpMethod: "POST"
      manageAlerts: true
      prometheusType: Prometheus
      prometheusVersion: 3.0.1
      exemplarTraceIdDestinations: []
    secureJsonData:
      basicAuthPassword: ${PROMETHEUS_PASSWORD}
    basicAuth: true
    basicAuthUser: admin
EOF
echo "✅ Datasource configuration created successfully"

echo "5. Creating dashboard configuration..."
cat > /etc/grafana/provisioning/dashboards/dashboard.yml << EOF
apiVersion: 1

providers:
  - name: 'Default'
    orgId: 1
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
      foldersFromFilesStructure: true
EOF
echo "✅ Dashboard configuration created successfully"

echo "6. Updating final permissions..."
chmod 644 /etc/grafana/provisioning/datasources/prometheus.yml
chown -R grafana:grafana /etc/grafana /var/lib/grafana /var/log/grafana
echo "✅ Final permissions set successfully"

echo "7. Verifying configurations..."
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
echo "✅ All configurations verified successfully"

echo "=== Initialization complete. Starting Grafana... ==="

cat << "EOF"

   ▄██████▄     ▄████████    ▄████████    ▄████████    ▄████████ ███▄▄▄▄      ▄████████ 
  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ ███▀▀▀██▄   ███    ███ 
  ███    █▀    ███    ███   ███    ███   ███    █▀    ███    ███ ███   ███   ███    ███ 
 ▄███         ▄███▄▄▄▄██▀   ███    ███  ▄███▄▄▄       ███    ███ ███   ███   ███    ███ 
▀▀███ ████▄  ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀     ▀███████████ ███   ███ ▀███████████ 
  ███    ███ ▀███████████   ███    ███   ███          ███    ███ ███   ███   ███    ███ 
  ███    ███   ███    ███   ███    ███   ███          ███    ███ ███   ███   ███    ███ 
  ████████▀    ███    ███   ███    █▀    ███          ███    █▀   ▀█   █▀    ███    █▀  
               ███    ███                                                               

EOF

# Start Grafana
exec grafana-server \
    --homepath=/usr/share/grafana \
    --config=/etc/grafana/grafana.ini