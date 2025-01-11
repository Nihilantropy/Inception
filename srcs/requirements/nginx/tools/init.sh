#!/bin/sh

echo "Creating folder for nginx certs"
mkdir -p /etc/nginx/certs

# Generate certificates if they don't exist
if [ ! -f "${SSL_CERTIFICATE_KEY}" ] || [ ! -f "${SSL_CERTIFICATE}" ]; then
    echo "Generating certification for Nginx..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${SSL_CERTIFICATE_KEY}" \
        -out "${SSL_CERTIFICATE}" \
        -subj "/C=IT/ST=Rome/L=Rome/O=WP/OU=WP/CN=${DOMAIN_NAME}" &&
    echo "Certificates generated!"
fi

echo "Creating nginx.conf file..."
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
        }

        # PHP-FPM routing
        location ~ \.php$ { 
            include fastcgi_params;
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

        # # Route for Gatsby App
        # location /gatsby-app/ {
        #     proxy_pass http://gatsby-app:3000;
        #     proxy_http_version 1.1;
        #     proxy_set_header Upgrade \$http_upgrade;
        #     proxy_set_header Connection 'upgrade';
        #     proxy_set_header Host \$host;
        #     proxy_cache_bypass \$http_upgrade;
        # }

        # # Route for AlienEggs App
        # location /alien-eggs/ {
        #     proxy_pass http://alien-eggs:8060/AlienEggs.html;
        #     proxy_http_version 1.1;
        #     proxy_set_header Upgrade \$http_upgrade;
        #     proxy_set_header Connection 'upgrade';
        #     proxy_set_header Host \$host;
        #     proxy_cache_bypass \$http_upgrade;
        # }

        # # Route for adminer
        # location /adminer/ {
        #     proxy_pass http://adminer:8080/;
        #     proxy_http_version 1.1;
        #     proxy_set_header Upgrade \$http_upgrade;
        #     proxy_set_header Connection 'upgrade';
        #     proxy_set_header Host \$host;
        #     proxy_cache_bypass \$http_upgrade;
        # }

        # location /prometheus/ {
        #     proxy_pass http://prometheus:9090/;
        #     proxy_http_version 1.1;
        #     proxy_set_header Upgrade \$http_upgrade;
        #     proxy_set_header Connection 'upgrade';
        #     proxy_set_header Host \$host;
        #     proxy_cache_bypass \$http_upgrade;
            
        #     # Basic auth for security
        #     auth_basic "Prometheus";
        #     auth_basic_user_file /etc/nginx/.htpasswd;
        # }

        # location /grafana/ {
        #     proxy_pass http://grafana:3000/;
        #     proxy_http_version 1.1;
        #     proxy_set_header Upgrade \$http_upgrade;
        #     proxy_set_header Connection 'upgrade';
        #     proxy_set_header Host \$host;
        #     proxy_cache_bypass \$http_upgrade;
        # }
    }
}
EOF
echo "nginx.conf file created successfully!"

# Create necessary directories for nginx
mkdir -p /var/log/nginx
mkdir -p /var/www/html
mkdir -p /run/nginx

# Start Nginx
echo "Starting nginx..."
exec nginx -g "daemon off;"