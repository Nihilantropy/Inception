#!/bin/sh
set -e

echo "=== Starting Python Server Initialization ==="

echo "1. Verifying Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: Python3 is not installed!"
    exit 1
fi
echo "✅ Python3 is available"

echo "2. Setting proper environment variables..."
# Ensure Python knows it's running in a Docker container
export DOCKER_CONTAINER=1
echo "✅ Environment variables set"

echo "3. Checking directory structure..."
if [ ! -d "/app/src" ]; then
    echo "❌ ERROR: Source directory not found!"
    exit 1
fi
if [ ! -f "/app/src/serve.py" ]; then
    echo "❌ ERROR: serve.py not found!"
    exit 1
fi
echo "✅ File structure verified"

echo "4. Preparing server environment..."
cd /app/src
chmod +x serve.py
echo "✅ Server environment prepared"

echo "=== Starting Python Server... ==="

cat << "EOF"


EOF                                                                    
