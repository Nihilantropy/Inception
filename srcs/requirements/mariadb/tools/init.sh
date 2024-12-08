#!/bin/sh

# Generate initialization SQL file
cat << EOF > /docker-entrypoint-initdb.d/init.sql
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Start MariaDB with the initialization file
exec mysqld --datadir="$MARIADB_DATA_DIR" --user=mysql --init-file=/docker-entrypoint-initdb.d/init.sql
