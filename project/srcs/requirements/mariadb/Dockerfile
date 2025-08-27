FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache mariadb mariadb-client

# Create run directory
RUN mkdir -p /run/mysqld /var/lib/mysql && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy config to correct Alpine path
COPY requirements/mariadb/conf/network.cnf /etc/my.cnf.d/network.cnf

# Copy entrypoint
COPY requirements/mariadb/conf/create_db.sh /usr/local/bin/create_db.sh
RUN chmod +x /usr/local/bin/create_db.sh

EXPOSE 3306
CMD ["/usr/local/bin/create_db.sh"]
