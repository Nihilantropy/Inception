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

echo "3. Generating nginx.conf..."
cat << EOF > /etc/nginx/nginx.conf
events {
    # Basic events configuration
    worker_connections 1024;
}

http {
    # Include MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Custom log format
    log_format custom_logs '\$remote_addr - \$remote_user [\$time_local] '
                            '"\$request" \$status \$body_bytes_sent '
                            '"\$http_referer" "\$http_user_agent" "\$request_body"';

    access_log /var/log/nginx/access.log custom_logs;

    server {
        # ====== HTTPS Configuration ======
        listen 443 ssl;
        listen [::]:443 ssl;

        server_name ${DOMAIN_NAME};

        ssl_certificate ${SSL_CERTIFICATE};
        ssl_certificate_key ${SSL_CERTIFICATE_KEY};

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
        # =================================

        # WordPress root directory
        root /var/www/html;
        index index.php index.html index.htm;

        location / {
            try_files \$uri \$uri/ /index.php?\$args;
            
            # Add proper MIME types
            include /etc/nginx/mime.types;
            default_type application/octet-stream;
            
            # Configure static file caching
            location ~* \.(css|js|jpg|jpeg|png|gif|ico|woff|woff2|ttf|svg)$ {
                expires 30d;
                access_log off;
                add_header Cache-Control "public, no-transform";
            }
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param PATH_INFO \$fastcgi_path_info;
            fastcgi_read_timeout 300;
        }

        # Route for Gatsby App
        location /gatsby-app/ {
            proxy_pass http://gatsby-app:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }

        # Route for AlienEggs App
        location /alien-eggs/ {
            proxy_pass http://alien-eggs:8060/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_proxy;

            # Add this rewrite rule to serve AlienEggs.html by default
            rewrite ^/alien-eggs/?$ /alien-eggs/AlienEggs.html permanent;
        }

        # Route for adminer
        location /adminer/ {
            proxy_pass http://adminer:8080/;
            proxy_http_version 1.1;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        location /prometheus/ {
            # Direct proxy to prometheus
            proxy_pass http://prometheus:9090/;
            
            # Essential proxy headers
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            
            # Websocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # Debug headers
            add_header X-Debug-Message "Proxying to Prometheus" always;
        }

        location /grafana/ {
            proxy_pass http://grafana:3000/;
			
            # Essential proxy headers
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            
            # Websocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
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

# Start Nginx
exec nginx -g "daemon off;"