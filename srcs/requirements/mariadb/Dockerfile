# Use Alpine as the base image
FROM alpine:3.19

# Set environment variables
ENV MARIADB_VERSION=10.6 \
    MARIADB_DATA_DIR=/var/lib/mysql \
    MYSQL_ROOT_PASSWORD=rootpassword \
    MYSQL_DATABASE=wordpress \
    MYSQL_USER=wordpress \
    MYSQL_PASSWORD=wordpresspassword

# Install MariaDB
RUN apk update && apk add --no-cache \
    mariadb mariadb-client && \
    mkdir -p "$MARIADB_DATA_DIR" && \
    chown -R mysql:mysql "$MARIADB_DATA_DIR"

# Configure MariaDB
COPY ./conf/my.cnf /etc/my.cnf
COPY ./initdb.d /docker-entrypoint-initdb.d

# Expose the MariaDB port
EXPOSE 3306

# Initialize and start MariaDB
CMD ["sh", "-c", "mysqld --datadir=$MARIADB_DATA_DIR --user=mysql --init-file=/docker-entrypoint-initdb.d/init.sql"]
