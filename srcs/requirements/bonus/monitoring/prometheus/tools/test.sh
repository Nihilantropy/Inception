#!/bin/sh

echo "=== Prometheus Connectivity Test ==="

# Test if Prometheus is listening
echo "\nTesting Prometheus port..."
nc -zv localhost 9090
if [ $? -eq 0 ]; then
    echo "✅ Prometheus is listening on port 9090"
else
    echo "❌ Prometheus is not listening on port 9090"
    exit 1
fi

# Test if Prometheus API is responding with auth
echo "\nTesting Prometheus API with auth..."
curl -f -s -u "admin:${PROMETHEUS_PASSWORD}" "http://localhost:9090/-/healthy"
if [ $? -eq 0 ]; then
    echo "✅ Prometheus API is responding"
else
    echo "❌ Prometheus API is not responding"
    echo "Trying verbose output for debugging:"
    curl -v -u "admin:${PROMETHEUS_PASSWORD}" "http://localhost:9090/-/healthy"
fi

# Test network connectivity from Nginx
echo "\nTesting connectivity from Nginx container..."
nc -zv prometheus 9090
if [ $? -eq 0 ]; then
    echo "✅ Can connect to Prometheus from Nginx"
else
    echo "❌ Cannot connect to Prometheus from Nginx"
fi

echo "\n=== Prometheus Health Check Debug ==="

echo "1. Testing health endpoint with wget..."
wget -O- --spider -v --auth-no-challenge --user=admin --password="${PROMETHEUS_PASSWORD}" \
    "http://localhost:9090/-/healthy"

echo "\n2. Testing with curl..."
curl -v -u "admin:${PROMETHEUS_PASSWORD}" "http://localhost:9090/-/healthy"

echo "\n3. Checking if Prometheus is listening..."
netstat -tulpn | grep 9090

echo "\n4. Checking Prometheus process..."
ps aux | grep prometheus | grep -v grep

echo "\n5. Testing ready endpoint..."
curl -v -u "admin:${PROMETHEUS_PASSWORD}" "http://localhost:9090/-/ready"

echo "\n6. Testing metrics endpoint..."
curl -v -u "admin:${PROMETHEUS_PASSWORD}" "http://localhost:9090/metrics"

echo "\n=== Test Complete ==="