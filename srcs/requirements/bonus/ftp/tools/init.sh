#!/bin/sh
set -e

# Set FTP user and password from environment variables
FTP_USER=${FTP_USER:-ftpuser}
FTP_PASS=${FTP_PASS:-password}

# Create required groups
addgroup -S www-data 2>/dev/null || true

# Create FTP user with specific home directory
adduser -D -h /var/www/html -s /bin/ash "${FTP_USER}" 2>/dev/null || true
adduser "${FTP_USER}" www-data 2>/dev/null || true

# Set the FTP password explicitly
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Configure PAM
cat > /etc/pam.d/vsftpd << EOF
auth    required pam_pwdfille.so
account required pam_permit.so
EOF

# Configure vsftpd
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
ftpd_banner=Welcome to FTP Server
EOF

# Create and set permissions for directories and log file
mkdir -p /var/run/vsftpd
mkdir -p /var/log
touch /var/log/vsftpd.log
chmod 755 /var/log/vsftpd.log
chown -R ${FTP_USER}:www-data /var/log/vsftpd.log

# Set up WordPress directory permissions
chown -R ${FTP_USER}:www-data /var/www/html
chmod -R 775 /var/www/html
usermod -aG www-data $FTP_USER 

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf