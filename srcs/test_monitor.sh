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

# Helper functions
print_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        return 1
    fi
}

time_request() {
    local start=$(date +%s%N)
    "$@"
    local status=$?
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    echo -e "${YELLOW}Request took ${duration}ms${NC}"
    return $status
}

grafana_api_call() {
    local endpoint=$1
    docker exec grafana curl -s -L \
        --fail \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
        "http://localhost:3000/grafana/api/${endpoint}"
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
echo "Testing Grafana health..."
if docker exec grafana curl -s -f "http://localhost:3000/grafana/api/health" > /dev/null; then
    print_result "Grafana health check"
else
    echo -e "${RED}✗ Grafana health check failed${NC}"
    exit 1
fi

echo "Testing Prometheus connectivity..."
echo "- Testing network reachability..."
docker exec grafana ping -c 1 prometheus
print_result "Network connectivity check"

echo "- Testing Prometheus authorization..."
docker exec -e PROMETHEUS_PASSWORD="${PROMETHEUS_PASSWORD}" grafana curl -s \
    -u "admin:${PROMETHEUS_PASSWORD}" \
    http://prometheus:9090/-/healthy
print_result "Prometheus authorization check"

echo "Checking Grafana datasource configuration..."
DATASOURCES=$(docker exec grafana curl -s -L --fail \
    -H "Accept: application/json" \
    -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
    "http://localhost:3000/api/datasources")

if [ $? -eq 0 ] && [ -n "$DATASOURCES" ]; then
    print_result "Datasource configuration accessible"
    if echo "$DATASOURCES" | grep -q '"name":"Prometheus"'; then
        print_result "Prometheus datasource found"
    else
        echo -e "${RED}✗ Prometheus datasource not found${NC}"
        echo "Available datasources:"
        echo "$DATASOURCES"
    fi
else
    echo -e "${RED}✗ Failed to access datasource configuration${NC}"
    echo "Response: $DATASOURCES"
fi

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
echo "Testing dashboard provisioning..."
DASHBOARD_RESPONSE=$(docker exec grafana curl -s -L --fail \
    -H "Accept: application/json" \
    -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
    "http://localhost:3000/api/search?type=dash-db")

if [ $? -eq 0 ] && [ -n "$DASHBOARD_RESPONSE" ]; then
    print_result "Dashboard API accessible"
    echo -e "\nFound Grafana dashboards:"
    echo "$DASHBOARD_RESPONSE" | grep -o '"title":"[^"]*"' | cut -d'"' -f4 || echo "No dashboards found"
    
    if echo "$DASHBOARD_RESPONSE" | grep -q '"title":"Alien Eggs Metrics"'; then
        print_result "Alien Eggs dashboard found"
    else
        echo -e "${RED}✗ Alien Eggs dashboard not found${NC}"
    fi
    
    if echo "$DASHBOARD_RESPONSE" | grep -q '"title":"Inception Container Metrics"'; then
        print_result "Container metrics dashboard found"
    else
        echo -e "${RED}✗ Container metrics dashboard not found${NC}"
    fi
else
    echo -e "${RED}✗ Failed to access dashboard configuration${NC}"
    echo "Response: $DASHBOARD_RESPONSE"
fi

echo -e "\n7. Testing Complete Monitoring Pipeline..."
echo "Generating test traffic..."
for i in {1..5}; do
    time_request curl -k -s "https://${DOMAIN_NAME}/alien-eggs/" > /dev/null
    echo -n "."
    sleep 1
done
echo ""

echo "Waiting for metrics to be collected..."
sleep 5

QUERY_RESULT=$(curl -k -s -u "admin:${PROMETHEUS_PASSWORD}" \
    "https://${DOMAIN_NAME}/prometheus/api/v1/query?query=increase(http_requests_total[1m])")

if [ $? -eq 0 ]; then
    REQUESTS=$(echo "$QUERY_RESULT" | grep -o '"value":\[[0-9.]*,[0-9.]*\]' | grep -o '[0-9.]*$')
    if [ -n "$REQUESTS" ] && [ $(echo "$REQUESTS > 0" | bc -l) -eq 1 ]; then
        print_result "Traffic recording test (recorded $REQUESTS requests)"
    else
        echo -e "${RED}✗ No traffic recorded in metrics${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Failed to query metrics${NC}"
    exit 1
fi

echo -e "\n8. Testing Service States..."
echo "Checking Docker container states:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}" | grep -E 'prometheus|grafana|cadvisor|alien-eggs'

echo -e "\n=== All Tests Completed ==="

# Cleanup
unset $(cat .env | grep -v '#' | sed 's/\r$//' | cut -d= -f1)