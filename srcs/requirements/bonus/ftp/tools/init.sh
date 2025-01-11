#!/bin/sh
set -e

# Set FTP user and password from environment variables
FTP_USER=${FTP_USER:-ftpuser}
FTP_PASS=${FTP_PASS:-password}

# # Create necessary groups and users for FTP
# echo "Creating FTP user..."
# addgroup -S ${FTP_USER}
# adduser -D -G ${FTP_USER} -h /home/${FTP_USER} $FTP_USER

# Set the FTP password
echo "$FTP_USER:$FTP_PASS" | chpasswd

# Configure vsftpd
echo "Creating vsftpd configuration file..."
cat > /etc/vsftpd/vsftpd.conf << EOF
# Allow local user login
local_enable=YES
write_enable=YES

# Restrict users to their home directory
chroot_local_user=YES

# Enable passive mode
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110

# Set the default FTP directory to match the WordPress directory
local_root=/var/www/html/

# Log FTP transactions
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES

# Security settings
anonymous_enable=NO
force_dot_files=NO

# Make sure we don't let vsftpd change file ownership
user_sub_token=$USER
local_umask=022

# Set the FTP server to run as ftpuser (instead of the default user)
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

listen=YES
listen_address=0.0.0.0
EOF

# # Add the user to the vsftpd user list to ensure it's recognized
# echo "$FTP_USER" > /etc/vsftpd/user_list

# Set up permissions to avoid vsftpd messing with ownership
chown -R $FTP_USER:www-data /var/www/html
chmod -R 755 /var/www/html

# Start the vsftpd service in the background
echo "Starting vsftpd server..."
vsftpd /etc/vsftpd/vsftpd.conf
