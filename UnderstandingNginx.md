# Understanding Nginx with Docker

This README explains how I use **Nginx** inside Docker, how it interprets requests, and how it connects with WordPress (via PHP-FPM). I want this to feel more like a walkthrough of how my config works.

---

## 🌍 How Nginx Sees Requests

When I type something into the browser, Nginx interprets it through `$uri`.

* If I visit → `https://mysite.com/about.html` → `$uri = /about.html`
* If I visit → `https://mysite.com/images/logo.png?size=200` → `$uri = /images/logo.png`

Notice that query strings like `?size=200` are ignored. That’s how Nginx knows what file to serve from disk.

---

## 🗂 My Config (Overview)

Here’s the important part of my Nginx config:

```nginx
server {
    listen 443 ssl;
    server_name <intra_user>.42.fr www.<intra_user>.42.fr;

    root /var/www/html;
    index index.php index.html;

    ssl_certificate     /etc/nginx/ssl/<intra_user>.42.fr.crt;
    ssl_certificate_key /etc/nginx/ssl/<intra_user>.42.fr.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_session_timeout 10m;
    keepalive_timeout   70;

    location / {
        try_files $uri /index.php?$args /index.html;
        add_header Last-Modified $date_gmt;
        add_header Cache-Control 'no-store, no-cache';
        if_modified_since off;
        expires off;
        etag off;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

---

## 🔑 Breaking Down the Blocks

### `location / { ... }`

This block handles requests to the root and static files like `/`, `/about`, `/images/logo.png`.

* `try_files $uri /index.php?$args /index.html;` → serve the file if it exists, otherwise hand off to WordPress (`index.php`).
* Headers (`Last-Modified`, `Cache-Control`) and directives (`expires off`, `etag off`) make sure caching doesn’t break dynamic WordPress pages.

### `location ~ \.php$ { ... }`

This block handles PHP requests like `/index.php` or `/wp-login.php`.

* `fastcgi_split_path_info ^(.+\.php)(/.+)$;` → splits the URI into the PHP script and extra path info.

  * Group 1 → `$fastcgi_script_name` (the PHP file itself).
  * Group 2 → `$fastcgi_path_info` (anything after the PHP file).
* `fastcgi_pass wordpress:9000;` → sends the request to the WordPress (PHP-FPM) container.
* `SCRIPT_FILENAME` → tells PHP-FPM which file to execute.
* `PATH_INFO` → optional, passed only if there’s extra path after the script name.

Example:

* `/index.php/test` →

  * `$fastcgi_script_name = /index.php`
  * `$fastcgi_path_info = /test`

---

## 🐳 Nginx in Docker

In my `docker-compose.yml`, I define Nginx like this:

```yaml
nginx:
  build:
    context: .
    dockerfile: requirements/nginx/Dockerfile
  container_name: nginx
  ports:
    - "443:443"
  volumes:
    - ./requirements/nginx/conf/:/etc/nginx/http.d/
    - ./requirements/nginx/tools:/etc/nginx/ssl/
    - /home/${USER}/simple_docker_nginx_html/public/html:/var/www/
  restart: always
```

* My SSL certs live in `requirements/nginx/tools`.
* My configs live in `requirements/nginx/conf/`.
* Static files are mounted into `/var/www/`.

---

## ✅ End Result

* When I request a static file (like `/images/logo.png`), Nginx serves it directly.
* When I request a PHP file (like `/wp-login.php`), Nginx forwards it to WordPress (PHP-FPM) on port `9000`.
* WordPress then talks to the database to build the final page.

This setup lets Nginx handle static assets efficiently, while still letting WordPress generate dynamic content.
