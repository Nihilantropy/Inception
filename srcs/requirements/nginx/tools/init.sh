#!/bin/sh
set -e

echo "=== Starting Nginx Initialization ==="

echo "1. Creating directory structure..."
echo "- Creating certificates directory"
mkdir -p /etc/nginx/certs
echo "- Creating log directory"
mkdir -p /var/log/nginx
echo "- Creating web root directory"
mkdir -p /var/www/html
echo "- Creating runtime directory"
mkdir -p /run/nginx
echo "✅ All directories created successfully"

echo "2. Setting up SSL certificates..."
if [ ! -f "${SSL_CERTIFICATE_KEY}" ] || [ ! -f "${SSL_CERTIFICATE}" ]; then
	echo "- Certificates not found, generating new ones..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout "${SSL_CERTIFICATE_KEY}" \
		-out "${SSL_CERTIFICATE}" \
		-subj "/C=IT/ST=Rome/L=Rome/O=WP/OU=WP/CN=${DOMAIN_NAME}"
	echo "✅ SSL certificates generated successfully"
else
	echo "✅ Using existing SSL certificates"
fi

echo "3. generating proxy_params file..."
cat << EOF > /etc/nginx/proxy_params
proxy_http_version 1.1;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection \$connection_upgrade;
proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;
EOF
echo "✅ proxy_params created succesfully!"

echo "4. Generating nginx.conf..."
cat << EOF > /etc/nginx/nginx.conf
events {
    # Each worker_connection handles multiple clients in non-blocking mode
    # 1024 is suitable for most scenarios without system tuning
	worker_connections 1024;
}

http {
    # Include MIME types and set defaults
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # WebSocket upgrade mapping
    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        '' close;
    }

    # Enhanced logging format
    log_format custom_logs '\$remote_addr - \$remote_user [\$time_local] '
                          '"\$request" \$status \$body_bytes_sent '
                          '"\$http_referer" "\$http_user_agent" "\$request_body"';
    access_log /var/log/nginx/access.log custom_logs;

    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name ${DOMAIN_NAME};

        # SSL Configuration
        ssl_certificate ${SSL_CERTIFICATE};
        ssl_certificate_key ${SSL_CERTIFICATE_KEY};
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';

        # Root and index
        root /var/www/html;
        index index.php index.html index.htm;

      	# === PHP Processing ===
		location ~ \.php$ {
			# Parses PHP URLs for proper routing
			fastcgi_split_path_info ^(.+\.php)(/.+)$;

			# Routes PHP requests to WordPress container
			fastcgi_pass wordpress:9000;
			fastcgi_index index.php;

			# Constructs absolute path to PHP script
			include fastcgi_params;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param PATH_INFO \$fastcgi_path_info;

			# Extended timeout for long-running scripts
			fastcgi_read_timeout 300;
		}

		# === Service Proxying ===

		# Route for Gatsby App
		location /gatsby-app/ {
			# Routes requests to Gatsby application
			proxy_pass http://gatsby-app:3000;
			
			# Include the necessary proxy_params
			include /etc/nginx/proxy_params;
		}

		# Route for AlienEggs App
		location /alien-eggs/ {
			# Routes requests to Alien-Eggs application
			proxy_pass http://alien-eggs:8060/;

			# Include the necessary proxy_params
			include /etc/nginx/proxy_params;

			# Add this rewrite rule to serve AlienEggs.html by default
			rewrite ^/alien-eggs/?$ /alien-eggs/AlienEggs.html permanent;
		}

		# Route for adminer
		location /adminer/ {
			# Routes requests to Adminer application
			proxy_pass http://adminer:8080/;

			# Include the necessary proxy_params
			include /etc/nginx/proxy_params;
		}

		# Route for prometheus
		location /prometheus/ {
			# Routes requests to Prometheus application
			proxy_pass http://prometheus:9090/;
			
			# Include the necessary proxy_params
			include /etc/nginx/proxy_params;
		}

		# Route for grafana
		location /grafana {
			# Routes requests to Grafana application
			proxy_pass http://grafana:3000;
			
			# Include the necessary proxy_params
			include /etc/nginx/proxy_params;
		}

		# Route for cadvisor
		location /cadvisor {
			# Routes requests to Cadvisor application
			proxy_pass http://cadvisor:8080;

			# Include the necessary proxy_params
			include /etc/nginx/proxy_params;
		}
    }
}
EOF
echo "✅ nginx.conf created successfully"

echo "4. Verifying configuration..."
if [ ! -f "/etc/nginx/nginx.conf" ]; then
	echo "❌ ERROR: nginx.conf not found!"
	exit 1
fi
if [ ! -f "${SSL_CERTIFICATE}" ] || [ ! -f "${SSL_CERTIFICATE_KEY}" ]; then
	echo "❌ ERROR: SSL certificates not found!"
	exit 1
fi
echo "✅ All configurations verified"

echo "5. Testing nginx configuration..."
nginx -t
if [ $? -ne 0 ]; then
	echo "❌ ERROR: Nginx configuration test failed!"
	exit 1
fi
echo "✅ Nginx configuration test passed"

echo "=== Initialization complete. Starting Nginx... ==="

cat << "EOF"

               _____               
______________ ___(_)__________  __
__  __ \_  __ `/_  /__  __ \_  |/_/
_  / / /  /_/ /_  / _  / / /_>  <  
/_/ /_/_\__, / /_/  /_/ /_//_/|_|  
       /____/                      

EOF

# Start Nginx
exec nginx -g "daemon off;"