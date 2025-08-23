FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache \
    php84 php84-fpm php84-mysqli php84-json php84-session php84-curl \
    php84-dom php84-xml php84-zip php84-gd php84-opcache curl tar

# www user + docroot
RUN adduser -D -g 'www' www && mkdir -p /var/www && chown -R www:www /var/www

COPY  requirements/wordpress/conf/wp-config-create.sh /usr/local/bin/wp-config-create.sh
RUN chmod +x /usr/local/bin/wp-config-create.sh

EXPOSE 9000
CMD ["/usr/local/bin/wp-config-create.sh"]
