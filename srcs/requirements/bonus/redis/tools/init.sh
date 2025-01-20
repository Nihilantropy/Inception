#!/bin/sh

echo "=== Starting REDIS Server Initialization ==="

# Configure Redis
echo "Configuring redis..."
echo "maxmemory 256mb" >> /etc/redis.conf
echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf
sed -i 's/^bind 127.0.0.1/#bind 127.0.0.1/' /etc/redis.conf
echo "✅ redis configuration done!"

# Ensure data persistence
echo "Creating necessary folder and setting ownership..."
mkdir -p /data && chown redis:redis /data
echo "✅ Set up done!"

cat << "EOF"


____/\\\\\\\\\____________________________/\\\_____________________        
 __/\\\///////\\\_________________________\/\\\_____________________       
  _\/\\\_____\/\\\_________________________\/\\\___/\\\______________      
   _\/\\\\\\\\\\\/________/\\\\\\\\_________\/\\\__\///___/\\\\\\\\\\_     
    _\/\\\//////\\\______/\\\/////\\\___/\\\\\\\\\___/\\\_\/\\\//////__    
     _\/\\\____\//\\\____/\\\\\\\\\\\___/\\\////\\\__\/\\\_\/\\\\\\\\\\_   
      _\/\\\_____\//\\\__\//\\///////___\/\\\__\/\\\__\/\\\_\////////\\\_  
       _\/\\\______\//\\\__\//\\\\\\\\\\_\//\\\\\\\/\\_\/\\\__/\\\\\\\\\\_ 
        _\///________\///____\//////////___\///////\//__\///__\//////////__
		

EOF

# Start redis server
exec redis-server /etc/redis.conf --protected-mode no