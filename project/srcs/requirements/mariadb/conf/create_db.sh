#!/bin/sh
set -e

# Initialize MariaDB system tables and database if not already present
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB system tables..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "Starting temporary MariaDB with init script..."
    # Create a temporary init script
    cat > /tmp/init.sql <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
        SHUTDOWN;
EOSQL

    # Run mysqld with init-file (runs script then exits automatically)
    mysqld --datadir=/var/lib/mysql --user=mysql --init-file=/tmp/init.sql --skip-networking

    # Clean up
    rm -f /tmp/init.sql
fi

echo "Starting MariaDB in foreground..."
exec mysqld --datadir=/var/lib/mysql --user=mysql
