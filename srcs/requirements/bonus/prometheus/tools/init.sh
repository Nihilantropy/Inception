#!/bin/sh
set -e

# Ensure necessary directories exist
mkdir -p /prometheus/data /etc/prometheus/certs
chown -R prometheus:prometheus /prometheus/data
chmod -R 775 /prometheus/data

# Generate SSL certificates if they don't exist
if [ ! -f "/etc/prometheus/certs/prometheus.key" ] || [ ! -f "/etc/prometheus/certs/prometheus.crt" ]; then
    echo "Generating SSL certificates for Prometheus..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/prometheus/certs/prometheus.key \
        -out /etc/prometheus/certs/prometheus.crt \
        -subj "/C=IT/ST=Rome/L=Rome/O=42/OU=42/CN=${DOMAIN_NAME}" \
        -addext "subjectAltName = DNS:${DOMAIN_NAME},DNS:prometheus"
    
    # Set proper permissions for SSL certificates
    chown prometheus:prometheus /etc/prometheus/certs/prometheus.crt
    chown prometheus:prometheus /etc/prometheus/certs/prometheus.key
    chmod 644 /etc/prometheus/certs/prometheus.crt
    chmod 600 /etc/prometheus/certs/prometheus.key
fi

# Generate web config with basic auth and TLS
echo "Generating web configuration..."
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

# Create web.yml with TLS and basic auth configuration
cat > /etc/prometheus/web.yml << EOF
tls_server_config:
  cert_file: /etc/prometheus/certs/prometheus.crt
  key_file: /etc/prometheus/certs/prometheus.key
  min_version: TLS12

basic_auth_users:
  admin: ${HASHED_PASSWORD}
EOF

chown prometheus:prometheus /etc/prometheus/web.yml
chmod 644 /etc/prometheus/web.yml

echo "Starting Prometheus with secure configuration..."
exec /prometheus/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus/data \
    --web.config.file=/etc/prometheus/web.yml \
    --web.listen-address=:9090 \
	--web.external-url=https://crea.42.it/prometheus/ \
    --web.enable-lifecycle \
    --web.enable-admin-api \
    --storage.tsdb.retention.time=15d