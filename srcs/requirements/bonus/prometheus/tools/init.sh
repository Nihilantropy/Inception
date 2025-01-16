#!/bin/sh
set -e

echo "=== Starting Prometheus Initialization ==="

echo "1. Generating password hash..."
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
    echo "❌ ERROR: Failed to generate password hash"
    exit 1
fi
echo "✅ Password hash generated successfully"

echo "2. Creating web.yml configuration..."
cat > /etc/prometheus/web.yml << EOF
# Basic authentication
basic_auth_users:
  admin: ${HASHED_PASSWORD}

# Other settings as needed
EOF
echo "✅ web.yml created successfully at /etc/prometheus/web.yml"

echo "3. Creating prometheus.yml configuration..."
cat > /etc/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'prometheus'
    basic_auth:
      username: 'admin'
      password: '${PROMETHEUS_PASSWORD}'
    metrics_path: '/metrics'
    scheme: 'http'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'alien-eggs'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['alien-eggs:8000']
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: '(http_requests_total|active_http_requests)'
        action: keep

  - job_name: 'cadvisor'
    scrape_interval: 5s
    static_configs:
      - targets: ['cadvisor:8080']
    metric_relabel_configs:
      - source_labels: [container_label_com_docker_compose_service]
        regex: '.+'
        target_label: service
      - source_labels: [container_label_com_docker_compose_project]
        regex: '.+'
        target_label: project
EOF
echo "✅ prometheus.yml created successfully at /etc/prometheus/prometheus.yml"

echo "4. Verifying configurations..."
if [ ! -f "/etc/prometheus/web.yml" ]; then
    echo "❌ ERROR: web.yml not found!"
    exit 1
fi
if [ ! -f "/etc/prometheus/prometheus.yml" ]; then
    echo "❌ ERROR: prometheus.yml not found!"
    exit 1
fi
echo "✅ All configuration files verified"

echo "5. Checking directory permissions..."
if [ ! -w "/prometheus/data" ]; then
    echo "❌ ERROR: Data directory is not writable!"
    exit 1
fi
echo "✅ Directory permissions verified"

echo "=== Initialization complete. Starting Prometheus... ==="
echo "Starting with configuration:"
echo "- Config file: /etc/prometheus/prometheus.yml"
echo "- Storage path: /prometheus/data"
echo "- Web config: /etc/prometheus/web.yml"
echo "- Listen address: :9090"
echo "- External URL: https://${DOMAIN_NAME}/prometheus/"
echo "- Route prefix: /"

cat << "EOF"

                                                                                                                     
        ##### ##                                                            /                                        
     ######  /###                                                         #/                                         
    /#   /  /  ###                                                  #     ##                                         
   /    /  /    ###                                                ##     ##                                         
       /  /      ##                                                ##     ##                                         
      ## ##      ## ###  /###     /###   ### /### /###     /##   ######## ##  /##      /##   ##   ####       /###    
      ## ##      ##  ###/ #### / / ###  / ##/ ###/ /##  / / ### ########  ## / ###    / ###   ##    ###  /  / #### / 
    /### ##      /    ##   ###/ /   ###/   ##  ###/ ###/ /   ###   ##     ##/   ###  /   ###  ##     ###/  ##  ###/  
   / ### ##     /     ##       ##    ##    ##   ##   ## ##    ###  ##     ##     ## ##    ### ##      ##  ####       
      ## ######/      ##       ##    ##    ##   ##   ## ########   ##     ##     ## ########  ##      ##    ###      
      ## ######       ##       ##    ##    ##   ##   ## #######    ##     ##     ## #######   ##      ##      ###    
      ## ##           ##       ##    ##    ##   ##   ## ##         ##     ##     ## ##        ##      ##        ###  
      ## ##           ##       ##    ##    ##   ##   ## ####    /  ##     ##     ## ####    / ##      /#   /###  ##  
      ## ##           ###       ######     ###  ###  ### ######/   ##     ##     ##  ######/   ######/ ## / #### /   
 ##   ## ##            ###       ####       ###  ###  ### #####     ##     ##    ##   #####     #####   ##   ###/    
###   #  /                                                                       /                                   
 ###    /                                                                       /                                    
  #####/                                                                       /                                     
    ###                                                                       /                                      

EOF

# Start Prometheus with validated configuration
exec /prometheus/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus/data \
    --web.config.file=/etc/prometheus/web.yml \
    --web.listen-address=:9090 \
    --web.external-url=https://${DOMAIN_NAME}/prometheus/ \
    --web.route-prefix=/