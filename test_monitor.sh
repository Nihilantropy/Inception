#!/bin/bash
set -e

echo "=== Testing Prometheus through Nginx ==="
if curl -k --fail -u "admin:prometheus_password" "https://crea.42.it/prometheus/-/healthy"; then
    echo "✅ Prometheus is healthy"
else
    echo "❌ Prometheus health check failed"
    exit 1
fi

echo -e "\n=== Testing Alien Eggs Metrics ==="
if docker exec nginx curl --fail http://alien-eggs:8000/metrics | grep "http_requests_total"; then
    echo "✅ Alien Eggs metrics are available"
else
    echo "❌ Alien Eggs metrics check failed"
    exit 1
fi

echo -e "\n=== Testing Grafana through Nginx ==="
if curl -k --fail "https://crea.42.it/grafana/api/health" | grep "ok"; then
    echo "✅ Grafana is healthy"
else
    echo "❌ Grafana health check failed"
    exit 1
fi

# Test full integration
echo -e "\n=== Testing Complete Integration ==="
echo "1. Accessing Alien Eggs app..."
curl -k -I "https://crea.42.it/alien-eggs/"

echo "2. Checking if metrics are being collected..."
# Fixed command with proper authentication
curl -k -s -u "admin:prometheus_password" "https://crea.42.it/prometheus/api/v1/query?query=http_requests_total" | jq .

echo -e "\n=== All Tests Completed ==="