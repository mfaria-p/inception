#!/bin/sh
set -e

WP_PATH="/var/www"
WP_CLI="/usr/local/bin/wp"

# Ensure PHP runtime dir exists
mkdir -p /run/php

# Install WP-CLI if missing
if [ ! -f "$WP_CLI" ]; then
    echo "Installing WP-CLI..."
    curl -s -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x /usr/local/bin/wp
fi

cd "$WP_PATH"

# Download WordPress core if missing
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root --path="$WP_PATH"
fi

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready at ${MYSQL_HOST}..."
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready!"

# Generate wp-config.php
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create \
      --dbname="${MYSQL_DATABASE}" \
      --dbuser="${MYSQL_USER}" \
      --dbpass="${MYSQL_PASSWORD}" \
      --dbhost="${MYSQL_HOST}" \
      --allow-root \
      --path="$WP_PATH"

    echo "define('FS_METHOD','direct');" >> "$WP_PATH/wp-config.php"
    echo "define('WP_HOME','https://${WP_URL}');" >> "$WP_PATH/wp-config.php"
    echo "define('WP_SITEURL','https://${WP_URL}');" >> "$WP_PATH/wp-config.php"
fi

# Run installation if not already installed
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
    echo "Installing WordPress..."
    wp core install \
      --url="https://${WP_URL}" \
      --title="${WP_TITLE}" \
      --admin_user="${WP_ADMIN_USER}" \
      --admin_password="${WP_ADMIN_PASS}" \
      --admin_email="${WP_ADMIN_MAIL}" \
      --allow-root \
      --path="$WP_PATH"

    # Optional: create a normal user
    wp user create "${WP_USER}" "${WP_USER_MAIL}" \
      --role=subscriber \
      --user_pass="${WP_USER_PASS}" \
      --allow-root \
      --path="$WP_PATH"
fi

# Fix permissions
chown -R www:www "$WP_PATH"
chmod -R 755 "$WP_PATH"

echo "Starting PHP-FPM..."
exec php-fpm84 -F

