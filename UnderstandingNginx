In Nginx, $uri = the part of the request that comes after the domain name, normalized (e.g., no query string).

Examples:

If you visit → https://mysite.com/about.html
→ $uri = /about.html

If you visit → https://mysite.com/images/logo.png?size=200
→ $uri = /images/logo.png (notice query string ?size=200 is ignored)

So yes — when you type something in the browser (or click a link), that becomes $uri.
That’s how Nginx decides what file (if any) to serve from disk.


location / { ... }

This block handles requests to your site’s root (like /, /about, /images/logo.png).

location / {
    try_files $uri /index.php?$args /index.html;
    add_header Last-Modified $date_gmt;
    add_header Cache-Control 'no-store, no-cache';
    if_modified_since off;
    expires off;
    etag off;
}

location ~ \.php$ { ... }

This block handles requests to PHP files (like /index.php or /wp-login.php).

location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass wordpress:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
}

$fastcgi_script_name → auto-set by Nginx when a .php request is matched.

$fastcgi_path_info → set only if you use fastcgi_split_path_info (otherwise it’s empty).



^(.+\.php)(/.+)$
This is a regular expression used by fastcgi_split_path_info. Its job is to split the request URI into two parts:

The PHP script itself → $fastcgi_script_name

Anything after it → $fastcgi_path_info

Step by step breakdown
^ → Match from the beginning of the string.

(.+\.php) →

.+ → one or more of any character.

\.php → literally the string .php (\. escapes the dot, otherwise dot = any char).

Together: “match everything up to and including .php”.

Captured as Group 1 → $fastcgi_script_name.

(/.+) →

/ → must be a literal slash.

.+ → one or more of any character.

Together: “match the slash and everything after it”.

Captured as Group 2 → $fastcgi_path_info.

$ → Match until the end of the string.
