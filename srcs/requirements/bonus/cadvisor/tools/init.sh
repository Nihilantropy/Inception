#!/bin/sh
set -e

echo "=== Starting cAdvisor Initialization ==="

echo "1. Verifying binary..."
if [ ! -x "/usr/local/bin/cadvisor" ]; then
    echo "❌ ERROR: cAdvisor binary not found or not executable!"
    exit 1
fi
echo "✅ cAdvisor binary verified"

echo "2. Creating necessary directories..."
# These directories should be mounted from host
for dir in /rootfs /var/run /sys /var/lib/docker /dev/disk; do
    if [ ! -d "$dir" ]; then
        echo "❌ ERROR: Required directory $dir not mounted!"
        exit 1
    fi
done
echo "✅ Required directories verified"

echo "3. Setting up storage parameters..."
STORAGE_DRIVER=${STORAGE_DRIVER:-"memory"}
STORAGE_DURATION=${STORAGE_DURATION:-"1h0m0s"}

echo "4. Configuring cAdvisor options..."
CADVISOR_OPTS="
  --port=8080 \
  --storage_duration=$STORAGE_DURATION \
  --housekeeping_interval=10s \
  --max_housekeeping_interval=15s \
  --global_housekeeping_interval=1m0s \
  --disable_metrics=advtcp,cpu_topology,cpuset,hugetlb,memory_numa,process,referenced_memory,resctrl,sched,tcp,udp \
  --docker_only=true \
  --docker=/var/run/docker.sock \
  --prometheus_endpoint=/metrics \
  --allow_dynamic_housekeeping=true \
  --event_storage_age_limit=1h0m0s \
  --event_storage_event_limit=100000 \
  --container_hints=/etc/cadvisor/container_hints.json"

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