#!/bin/sh
set -e

# Initialize MariaDB system tables and database if not already present
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB system tables..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "Starting temporary MariaDB..."
    mysqld --datadir=/var/lib/mysql --user=mysql --skip-networking=0 --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    echo "Waiting for MariaDB to be ready..."
    until mariadb -uroot --socket=/run/mysqld/mysqld.sock -e "SELECT 1;" >/dev/null 2>&1; do
        sleep 2
    done

    echo "Creating database and user..."
    mariadb -uroot --socket=/run/mysqld/mysqld.sock <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "Shutting down temporary MariaDB..."
    kill "$pid"
    wait "$pid"
fi

echo "Starting MariaDB in foreground..."
exec mysqld --datadir=/var/lib/mysql --user=mysql
