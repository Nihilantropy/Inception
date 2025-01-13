#!/bin/sh

echo "=== FTP Connection Test ==="

# Install required packages
apk add --no-cache curl ncftp netcat-openbsd

# Test basic connection
echo "\nTesting connection to FTP server..."
if nc -zv ftp 21; then
    echo "✅ Connection successful"
else
    echo "❌ Connection failed"
    exit 1
fi

# Create test file
echo "Hello FTP" > test.txt

# Test file upload
echo "\nTesting file upload..."
curl -v --user "${FTP_USER}:${FTP_PASS}" -T test.txt ftp://ftp/test.txt
if [ $? -eq 0 ]; then
    echo "✅ Upload successful"
else
    echo "❌ Upload failed"
fi

# Test directory listing
echo "\nTesting directory listing..."
curl -v --user "${FTP_USER}:${FTP_PASS}" ftp://ftp/
if [ $? -eq 0 ]; then
    echo "✅ Directory listing successful"
else
    echo "❌ Directory listing failed"
fi

# Cleanup
rm -f test.txt

# Print logs
echo "\nFTP Server Logs:"
docker exec ftp cat /var/log/vsftpd.log