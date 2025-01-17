#!/bin/bash
set -e

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    export $(cat .env | grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}')
else
    echo "Error: .env file not found in the current directory!"
    exit 1
fi

# Verify required environment variables
required_vars=(
    "DOMAIN_NAME"
    "PROMETHEUS_PASSWORD"
    "GF_SECURITY_ADMIN_USER"
    "GF_SECURITY_ADMIN_PASSWORD"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required environment variable $var is not set!"
        exit 1
    fi
done

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper function for success/failure messages
print_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        return 1
    fi
}

# Helper function for timing requests
time_request() {
    local start=$(date +%s%N)
    "$@"
    local status=$?
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    echo -e "${YELLOW}Request took ${duration}ms${NC}"
    return $status
}

echo "=== Testing Individual Services Health ==="

echo -e "\n1. Testing Prometheus..."
# Test basic health
time_request curl -k --fail -s -u "admin:${PROMETHEUS_PASSWORD}" "https://${DOMAIN_NAME}/prometheus/-/healthy" > /dev/null
print_result "Basic health check"

# Test metrics endpoint
time_request curl -k --fail -s -u "admin:${PROMETHEUS_PASSWORD}" "https://${DOMAIN_NAME}/prometheus/api/v1/targets" | grep -q "\"health\":\"up\""
print_result "Metrics endpoint check"

echo -e "\n2. Testing cAdvisor..."
# Test health endpoint through Nginx
time_request curl -k --fail -s "https://${DOMAIN_NAME}/cadvisor/healthz" > /dev/null
print_result "Health endpoint check"

# Test metrics availability through Nginx
time_request curl -k --fail -s "https://${DOMAIN_NAME}/cadvisor/metrics" | grep -q "container_"
print_result "Metrics availability"

echo -e "\n3. Testing Grafana..."
# Test basic health from inside the container
echo "Testing Grafana health..."
docker exec grafana curl -s "http://localhost:3000/api/health" | grep -q "\"database\":\"ok\""
print_result "Grafana database health check"

# Test Prometheus data source from inside the container
echo "Testing Prometheus data source connection..."
docker exec grafana curl -s \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
    "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up" | grep -q "\"status\":\"success\""
print_result "Prometheus data source connection check"

echo -e "\n=== Testing Metrics Collection ==="

echo -e "\n4. Testing Alien Eggs Metrics Collection..."
# Test if Alien Eggs metrics are being collected
time_request curl -k -s -u "admin:${PROMETHEUS_PASSWORD}" \
    "https://${DOMAIN_NAME}/prometheus/api/v1/query?query=http_requests_total" | grep -q "\"resultType\":\"vector\""
print_result "HTTP requests metrics collection"

# Test active requests gauge
time_request curl -k -s -u "admin:${PROMETHEUS_PASSWORD}" \
    "https://${DOMAIN_NAME}/prometheus/api/v1/query?query=active_http_requests" | grep -q "\"resultType\":\"vector\""
print_result "Active requests metrics collection"

echo -e "\n5. Testing Container Metrics Collection..."
# Test various container metrics
metrics_to_test=(
    "container_memory_usage_bytes"
    "container_cpu_usage_seconds_total"
    "container_network_receive_bytes_total"
)

for metric in "${metrics_to_test[@]}"; do
    time_request curl -k -s -u "admin:${PROMETHEUS_PASSWORD}" \
        "https://${DOMAIN_NAME}/prometheus/api/v1/query?query=${metric}" | grep -q "\"resultType\":\"vector\""
    print_result "Container ${metric} collection"
done

echo -e "\n6. Testing Grafana Dashboards..."
# Let's test this through the nginx proxy by using docker exec to access grafana's API
echo "Testing dashboard provisioning..."
docker exec grafana curl -s \
    -H "Accept: application/json" \
    -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
    "http://localhost:3000/api/search?type=dash-db" > /tmp/grafana_dashboards.json

# Check if we got any dashboards
if [ -s "/tmp/grafana_dashboards.json" ]; then
    echo -e "\nFound Grafana dashboards:"
    cat /tmp/grafana_dashboards.json | jq -r '.[].title' 2>/dev/null || echo "No dashboards found or jq not installed"
    
    # Check for specific dashboards
    if cat /tmp/grafana_dashboards.json | grep -q "alien-eggs-metrics"; then
        print_result "Alien Eggs dashboard found"
    else
        echo -e "${RED}✗ Alien Eggs dashboard not found${NC}"
    fi
    
    if cat /tmp/grafana_dashboards.json | grep -q "inception-containers"; then
        print_result "Container metrics dashboard found"
    else
        echo -e "${RED}✗ Container metrics dashboard not found${NC}"
    fi
else
    echo -e "${RED}✗ No dashboards found or couldn't access Grafana API${NC}"
fi

rm -f /tmp/grafana_dashboards.json

echo -e "\n7. Testing Complete Monitoring Pipeline..."
echo "Generating test traffic..."
for i in {1..5}; do
    time_request curl -k -s "https://${DOMAIN_NAME}/alien-eggs/" > /dev/null
    echo -n "."
    sleep 1
done
echo ""

# Check if traffic is recorded in Prometheus
echo "Waiting for metrics to be collected..."
sleep 5
QUERY_RESULT=$(curl -k -s -u "admin:${PROMETHEUS_PASSWORD}" \
    "https://${DOMAIN_NAME}/prometheus/api/v1/query?query=increase(http_requests_total[1m])")

echo "Query result: $QUERY_RESULT"

REQUESTS=$(echo "$QUERY_RESULT" | grep -o '"value":\[[0-9.]*,[0-9.]*\]' | grep -o '[0-9.]*$')

if [ -n "$REQUESTS" ] && [ $(echo "$REQUESTS > 0" | bc -l) -eq 1 ]; then
    print_result "Traffic recording test (recorded $REQUESTS requests)"
else
    echo -e "${RED}✗ No traffic recorded in metrics${NC}"
    exit 1
fi

echo -e "\n8. Testing Service States..."
echo "Checking Docker container states:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}" | grep -E 'prometheus|grafana|cadvisor|alien-eggs'

echo -e "\n=== All Tests Completed ==="

# Cleanup
unset $(cat .env | grep -v '#' | sed 's/\r$//' | cut -d= -f1)