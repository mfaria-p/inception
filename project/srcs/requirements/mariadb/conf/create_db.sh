#!/bin/sh
set -e

# Initialize database if not already present
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start MariaDB in safe mode (background)
mariadbd-safe --datadir=/var/lib/mysql --user=mysql &
pid="$!"

# Wait until MariaDB is ready
echo "Waiting for MariaDB to start..."
until mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done

# Create database and user if they don't exist
echo "Configuring database..."
mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

# Bring MariaDB to foreground
wait "$pid"
