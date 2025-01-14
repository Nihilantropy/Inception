#!/bin/sh

echo "=== Prometheus Connectivity Test ==="

# Test if Prometheus is listening
echo "\nTesting Prometheus port..."
nc -zv localhost 9090
if [ $? -eq 0 ]; then
    echo "✅ Prometheus is listening on port 9090"
else
    echo "❌ Prometheus is not listening on port 9090"
fi

# Test if Prometheus API is responding
echo "\nTesting Prometheus API..."
curl -v http://localhost:9090/-/healthy
if [ $? -eq 0 ]; then
    echo "✅ Prometheus API is responding"
else
    echo "❌ Prometheus API is not responding"
fi

# Test network connectivity from Nginx
echo "\nTesting connectivity from Nginx container..."
nc -zv prometheus 9090
if [ $? -eq 0 ]; then
    echo "✅ Can connect to Prometheus from Nginx"
else
    echo "❌ Cannot connect to Prometheus from Nginx"
fi