#!/bin/sh
set -e

# Ensure necessary directories exist and have correct permissions
mkdir -p /prometheus/data
touch /prometheus/data/queries.active
chown -R prometheus:prometheus /prometheus/data
chmod -R 775 /prometheus/data
chmod 664 /prometheus/data/queries.active

# Ensure necessary directories exist with proper permissions
mkdir -p /etc/prometheus/certs
mkdir -p /prometheus/data

# Generate certificates if they don't exist
if [ ! -f "/etc/prometheus/certs/prometheus.key" ] || [ ! -f "/etc/prometheus/certs/prometheus.crt" ]; then
    echo "Generating certificates for Prometheus..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/prometheus/certs/prometheus.key \
        -out /etc/prometheus/certs/prometheus.crt \
        -subj "/C=IT/ST=Rome/L=Rome/O=42/OU=42/CN=prometheus.crea.42.it"
    echo "Certificates generated!"
fi

# Generate the web.yml file with the hashed password
echo "Generating web configuration..."
# Generate bcrypt hash using Python with proper error handling
HASHED_PASSWORD=$(python3 -c "
import bcrypt, sys
try:
    password = '${PROMETHEUS_PASSWORD}'.encode()
    print(bcrypt.hashpw(password, bcrypt.gensalt(rounds=10)).decode())
except Exception as e:
    print(f'Error generating hash: {e}', file=sys.stderr)
    sys.exit(1)
")

if [ $? -ne 0 ]; then
    echo "Failed to generate password hash"
    exit 1
fi

cat > /etc/prometheus/web.yml << EOF
tls_server_config:
  cert_file: /etc/prometheus/certs/prometheus.crt
  key_file: /etc/prometheus/certs/prometheus.key

basic_auth_users:
  admin: ${HASHED_PASSWORD}
EOF

# Set correct ownership of generated files
chown -R prometheus:prometheus /etc/prometheus/certs
chown prometheus:prometheus /etc/prometheus/web.yml
chmod 600 /etc/prometheus/certs/prometheus.key

# Start Prometheus with proper error handling
echo "Starting Prometheus..."
exec /prometheus/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus/data \
    --web.config.file=/etc/prometheus/web.yml \
    --web.listen-address=:9090