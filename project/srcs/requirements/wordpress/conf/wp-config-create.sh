#!/bin/sh
set -e

if [ ! -f /var/www/index.php ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /var/www --strip-components=1
    chown -R www:www /var/www
fi

echo "Starting PHP-FPM..."
exec php-fpm84 -F

