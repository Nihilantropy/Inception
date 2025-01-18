#!/bin/sh
set -e

echo "=== Starting Python Server Initialization ==="

echo "1. Verifying Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: Python3 is not installed!"
    exit 1
fi
echo "✅ Python3 is available"

echo "2. Checking directory structure..."
if [ ! -d "/app/src" ]; then
    echo "❌ ERROR: Source directory not found!"
    exit 1
fi
echo "✅ Directory structure verified"

echo "3. Verifying serve.py exists..."
if [ ! -f "/app/src/serve.py" ]; then
    echo "❌ ERROR: serve.py not found!"
    exit 1
fi
echo "✅ serve.py found"

echo "=== Initialization complete. Starting Python server... ==="

cat << "EOF"

 ▄▄▄       ██▓     ██▓▓█████  ███▄    █ ▓█████   ▄████   ▄████   ██████ 
▒████▄    ▓██▒    ▓██▒▓█   ▀  ██ ▀█   █ ▓█   ▀  ██▒ ▀█▒ ██▒ ▀█▒▒██    ▒ 
▒██  ▀█▄  ▒██░    ▒██▒▒███   ▓██  ▀█ ██▒▒███   ▒██░▄▄▄░▒██░▄▄▄░░ ▓██▄   
░██▄▄▄▄██ ▒██░    ░██░▒▓█  ▄ ▓██▒  ▐▌██▒▒▓█  ▄ ░▓█  ██▓░▓█  ██▓  ▒   ██▒
 ▓█   ▓██▒░██████▒░██░░▒████▒▒██░   ▓██░░▒████▒░▒▓███▀▒░▒▓███▀▒▒██████▒▒
 ▒▒   ▓▒█░░ ▒░▓  ░░▓  ░░ ▒░ ░░ ▒░   ▒ ▒ ░░ ▒░ ░ ░▒   ▒  ░▒   ▒ ▒ ▒▓▒ ▒ ░
  ▒   ▒▒ ░░ ░ ▒  ░ ▒ ░ ░ ░  ░░ ░░   ░ ▒░ ░ ░  ░  ░   ░   ░   ░ ░ ░▒  ░ ░
  ░   ▒     ░ ░    ▒ ░   ░      ░   ░ ░    ░   ░ ░   ░ ░ ░   ░ ░  ░  ░  
      ░  ░    ░  ░ ░     ░  ░         ░    ░  ░      ░       ░       ░  
                                                                        
EOF                                                                    

# Execute the Python server
exec python3 src/serve.py --root /app/src --no-browser