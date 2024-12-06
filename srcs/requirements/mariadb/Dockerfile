# Use Alpine as the base image
FROM alpine:3.19

# Set environment variables
ENV MARIADB_DATA_DIR=/var/lib/mysql

# Install MariaDB
RUN apk update && apk add --no-cache \
    mariadb mariadb-client && \
    mkdir -p "$MARIADB_DATA_DIR" && \
    chown -R mysql:mysql "$MARIADB_DATA_DIR" && \
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Configure MariaDB
COPY ./conf/my.cnf /etc/my.cnf
COPY ./tools/init.sql /docker-entrypoint-initdb.d/init.sql

# Expose the MariaDB port
EXPOSE 3306

# Initialize and start MariaDB
CMD ["sh", "-c", "mysqld --datadir=$MARIADB_DATA_DIR --user=mysql --init-file=/docker-entrypoint-initdb.d/init.sql"]
