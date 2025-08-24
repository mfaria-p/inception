#!/bin/sh
set -e

# Download WordPress core if not already present
if [ ! -f /var/www/index.php ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /var/www --strip-components=1
    chown -R www:www /var/www
fi

# Create wp-config.php if not already present
if [ ! -f /var/www/wp-config.php ]; then
    echo "Creating wp-config.php..."
    cp /var/www/wp-config-sample.php /var/www/wp-config.php

    # Replace placeholders with env vars
    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" /var/www/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/wp-config.php
    sed -i "s/localhost/${MYSQL_HOST}/" /var/www/wp-config.php

    chown www:www /var/www/wp-config.php
fi

echo "Starting PHP-FPM..."
exec php-fpm84 -F

