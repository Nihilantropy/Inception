#!/bin/sh
set -e

echo "=== Grafana Debug Script ==="

echo "1. Checking Grafana process..."
if ps aux | grep grafana-server > /dev/null; then
    echo "✅ Grafana process is running"
    ps aux | grep grafana-server
else
    echo "❌ Grafana process is not running"
fi

echo "2. Checking Grafana logs..."
if [ -f "/var/log/grafana/grafana.log" ]; then
    echo "✅ Found Grafana logs"
    tail -n 20 /var/log/grafana/grafana.log
else
    echo "❌ No Grafana log file found"
fi

echo "3. Testing direct Grafana connection..."
HEALTH_CHECK=$(wget -qO- --no-check-certificate http://localhost:3000/api/health || echo "FAILED")
if [ "$HEALTH_CHECK" != "FAILED" ]; then
    echo "✅ Grafana API is responding"
    echo "$HEALTH_CHECK"
else
    echo "❌ Failed to connect to Grafana API"
fi

echo "4. Verifying configuration values..."
if [ -f "/etc/grafana/grafana.ini" ]; then
    echo "✅ Found grafana.ini configuration"
    cat /etc/grafana/grafana.ini
else
    echo "❌ grafana.ini not found"
fi

echo "5. Testing network connectivity..."
if nc -zv prometheus 9090; then
    echo "✅ Successfully connected to Prometheus"
else
    echo "❌ Failed to connect to Prometheus"
fi

echo "6. Checking directory permissions..."
echo "Checking /etc/grafana:"
ls -la /etc/grafana
echo "✅ Permission check complete for /etc/grafana"

echo "Checking /var/lib/grafana:"
ls -la /var/lib/grafana
echo "✅ Permission check complete for /var/lib/grafana"

echo "Checking /var/log/grafana:"
ls -la /var/log/grafana
echo "✅ Permission check complete for /var/log/grafana"

echo "7. Checking environment variables..."
ENV_VARS=$(env | grep -i "GF_\|DOMAIN")
if [ -n "$ENV_VARS" ]; then
    echo "✅ Found Grafana environment variables:"
    echo "$ENV_VARS"
else
    echo "❌ No Grafana environment variables found"
fi

echo "=== Debug Complete ==="