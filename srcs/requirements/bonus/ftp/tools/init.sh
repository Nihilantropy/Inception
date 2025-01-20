#!/bin/sh
set -e

echo "=== Starting FTP Server Initialization ==="

echo "1. Setting up user environment..."
echo "- Setting FTP user and password from environment variables"
FTP_USER=${FTP_USER:-ftpuser}
FTP_PASS=${FTP_PASS:-password}

echo "2. Creating system groups and users..."
echo "- Creating www-data group..."
addgroup -S www-data 2>/dev/null || true

echo "- Creating FTP user: ${FTP_USER}"
adduser -D -h /var/www/html -s /bin/ash "${FTP_USER}" 2>/dev/null || true
adduser "${FTP_USER}" www-data 2>/dev/null || true

echo "- Setting FTP user password..."
if echo "${FTP_USER}:${FTP_PASS}" | chpasswd; then
    echo "✅ User setup completed successfully"
else
    echo "❌ ERROR: Failed to set user password!"
    exit 1
fi

echo "3. Setting up SSL certificates..."
if [ ! -f "${FTP_SSL_CERTIFICATE}" ] || [ ! -f "${FTP_SSL_CERTIFICATE_KEY}" ]; then
    echo "- Generating new SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${FTP_SSL_CERTIFICATE_KEY}" \
        -out "${FTP_SSL_CERTIFICATE}" \
        -subj "/C=IT/ST=Rome/L=Rome/O=42/OU=42/CN=ftp.${DOMAIN_NAME}"
    
    chmod 600 "${FTP_SSL_CERTIFICATE_KEY}"
    chmod 644 "${FTP_SSL_CERTIFICATE}"
    echo "✅ SSL certificates generated successfully"
fi

echo "4. Configuring PAM authentication..."
cat > /etc/pam.d/vsftpd << EOF
auth    required pam_pwdfille.so
account required pam_permit.so
EOF
echo "✅ PAM configuration created"

echo "5. Creating VSFTPD configuration..."
cat > /etc/vsftpd/vsftpd.conf << EOF
# Standalone mode
listen=YES
listen_port=21
listen_address=0.0.0.0
background=NO
max_clients=10

# Access Control
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022

# Security
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
dirlist_enable=YES
download_enable=YES

# SSL Configuration
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
rsa_cert_file=${FTP_SSL_CERTIFICATE}
rsa_private_key_file=${FTP_SSL_CERTIFICATE_KEY}
ssl_request_cert=NO

# Local User Config
user_sub_token=\$USER
local_root=/var/www/html
guest_enable=NO
virtual_use_local_privs=YES

# Logging
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES
debug_ssl=YES

# Passive Mode Config
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=0.0.0.0

# Timeout Config
idle_session_timeout=300
data_connection_timeout=300
accept_timeout=60
connect_timeout=60

# System Settings
seccomp_sandbox=NO
ascii_upload_enable=YES
ascii_download_enable=YES
ftpd_banner=Welcome to FTP Server with SSL/TLS
EOF
echo "✅ VSFTPD configuration created"

echo "6. Setting up directories and permissions..."
echo "- Creating required directories..."
mkdir -p /var/run/vsftpd
mkdir -p /var/log

echo "- Creating and configuring log file..."
touch /var/log/vsftpd.log
chmod 755 /var/log/vsftpd.log
chown -R ${FTP_USER}:www-data /var/log/vsftpd.log

echo "- Setting WordPress directory permissions..."
chown -R ${FTP_USER}:www-data /var/www/html
chmod -R 775 /var/www/html
usermod -aG www-data $FTP_USER
echo "✅ Directories and permissions configured"

echo "7. Verifying configuration..."
if [ ! -f "/etc/vsftpd/vsftpd.conf" ]; then
    echo "❌ ERROR: VSFTPD configuration not found!"
    exit 1
fi
if [ ! -f "${FTP_SSL_CERTIFICATE}" ] || [ ! -f "${FTP_SSL_CERTIFICATE_KEY}" ]; then
    echo "❌ ERROR: SSL certificates not found!"
    exit 1
fi
if [ ! -f "/var/log/vsftpd.log" ]; then
    echo "❌ ERROR: Log file not created!"
    exit 1
fi
if ! id -u "${FTP_USER}" >/dev/null 2>&1; then
    echo "❌ ERROR: FTP user not created correctly!"
    exit 1
fi
echo "✅ All configurations verified"

echo "=== Initialization complete. Starting VSFTPD... ==="

cat << "EOF"
                              
      ___           ___           ___     
     /  /\         /__/\         /  /\    
    /  /::\        \  \:\       /  /::\   
   /  /:/\:\        \__\:\     /  /:/\:\  
  /  /::\ \:\       /  /::\   /  /::\ \:\ 
 /__/:/\:\ \:\     /  /:/\:\ /__/:/\:\_\:\
 \__\/  \:\_\/    /  /:/__\/ \__\/  \:\/:/
      \  \:\     /__/:/           \  \::/ 
       \__\/     \__\/             \__\/  
                                          

EOF

# Start VSFTPD
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf