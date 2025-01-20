#!/bin/sh

echo "Creating initdb.d directory..."
mkdir -p initdb.d
echo "✅ Directory created succesfully!"

# Generate initialization SQL file
echo "Creating init.sql file for db and user setup..."
cat << EOF > /initdb.d/init.sql
-- Create the specified database
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;

-- Create a non-root user and grant privileges
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

-- Set root password and allow root access from any host
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Flush privileges to apply changes
FLUSH PRIVILEGES;
EOF

echo "✅ init.sql created succesfully!"

echo "======== Starting Mariadb ========"

cat << "EOF"

,---.    ,---.   ____    .-------.   .-./`)    ____     ______      _______    
|    \  /    | .'  __ `. |  _ _   \  \ .-.') .'  __ `. |    _ `''. \  ____  \  
|  ,  \/  ,  |/   '  \  \| ( ' )  |  / `-' \/   '  \  \| _ | ) _  \| |    \ |  
|  |\_   /|  ||___|  /  ||(_ o _) /   `-'`"`|___|  /  ||( ''_'  ) || |____/ /  
|  _( )_/ |  |   _.-`   || (_,_).' __ .---.    _.-`   || . (_) `. ||   _ _ '.  
| (_ o _) |  |.'   _    ||  |\ \  |  ||   | .'   _    ||(_    ._) '|  ( ' )  \ 
|  (_,_)  |  ||  _( )_  ||  | \ `'   /|   | |  _( )_  ||  (_.\.' / | (_{;}_) | 
|  |      |  |\ (_ o _) /|  |  \    / |   | \ (_ o _) /|       .'  |  (_,_)  / 
'--'      '--' '.(_,_).' ''-'   `'-'  '---'  '.(_,_).' '-----'`    /_______.'  
                                                                               
EOF

# Start MariaDB with the initialization file
exec mysqld --datadir="$MARIADB_DATA_DIR" --user=mysql --init-file=/initdb.d/init.sql
