#!/bin/sh
set -e

echo "=== Starting cAdvisor Initialization ==="

echo "1. Setting up permissions..."
# Ensure docker socket has correct permissions
if [ -S "/var/run/docker.sock" ]; then
    chmod 666 /var/run/docker.sock
    chown root:docker /var/run/docker.sock
fi

# Ensure kmsg is accessible
if [ -c "/dev/kmsg" ]; then
    chmod 644 /dev/kmsg
fi

echo "2. Verifying binary..."
if [ ! -x "/usr/local/bin/cadvisor" ]; then
    echo "❌ ERROR: cAdvisor binary not found or not executable!"
    exit 1
fi
echo "✅ cAdvisor binary verified"

echo "3. Creating necessary directories..."
# These directories should be mounted from host
for dir in /rootfs /var/run /sys /var/lib/docker /dev/disk; do
    if [ ! -d "$dir" ]; then
        echo "❌ ERROR: Required directory $dir not mounted!"
        exit 1
    fi
done
echo "✅ Required directories verified"

echo "4. Configuring cAdvisor options..."
CADVISOR_OPTS="
  --port=8080 \
  --storage_duration=1m \
  --housekeeping_interval=10s \
  --max_housekeeping_interval=15s \
  --global_housekeeping_interval=1m0s \
  --disable_metrics=advtcp,cpu_topology,cpuset,hugetlb,memory_numa,process,referenced_memory,resctrl,sched,tcp,udp \
  --docker_only=true \
  --docker=unix:///var/run/docker.sock \
  --allow_dynamic_housekeeping=true \
  --url_base_prefix=/cadvisor \
  --docker_env_metadata_whitelist=container_name,HOSTNAME"

echo "=== Initialization complete. Starting cAdvisor... ==="

cat << "EOF"

   ___          _       _                
  / __\__ _  __| |_   _(_)___  ___  _ __ 
 / /  / _` |/ _` \ \ / / / __|/ _ \| '__|
/ /__| (_| | (_| |\ V /| \__ \ (_) | |   
\____/\__,_|\__,_| \_/ |_|___/\___/|_|   
                                                  

EOF

# Start cAdvisor with configured options
exec /usr/local/bin/cadvisor $CADVISOR_OPTS