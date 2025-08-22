# Understanding WordPress with Docker

This README explains how I run WordPress in a Docker setup, how it connects to **Nginx** and the **database**, and where the website files actually live.
It’s not just a setup guide — I want it to give a clear understanding of the moving parts.

---

## 🌍 What is WordPress?

WordPress is a **PHP-based content management system (CMS)**. It builds dynamic websites by combining:

* **PHP files** → the logic of WordPress (core files, themes, plugins).
* **Database (MySQL/MariaDB)** → stores posts, pages, users, settings.
* **Static assets** → HTML, CSS, JS, and images that are served directly.

When I type `https://mysite.com`, **Nginx** serves the WordPress files, **PHP-FPM** executes them, and WordPress queries the database to generate the page.

---

## 📂 Where do the files live?

### WordPress files (PHP + themes + plugins)

In my `docker-compose.yml` I have:

```yaml
wordpress:
  build: ./requirements/wordpress
  volumes:
    - wp_data:/var/www/html
```

Inside the WordPress container, WordPress installs itself into `/var/www/html` (defined in my custom Dockerfile under `requirements/wordpress`).

That folder is shared with the **Nginx** container using the named volume `wp_data`. This means **Nginx** and **WordPress** see the same files.

For example: when Nginx serves `https://mysite.com/wp-login.php`, it finds `wp-login.php` inside `/var/www/html` — coming directly from WordPress.

---

## 🔑 How the volume actually works (step by step)

### 1. Define the volume in `docker-compose.yml`

```yaml
volumes:
  wp_data:
```

This creates an empty named volume called `wp_data`.

### 2. WordPress mounts it into `/var/www/html`

```yaml
wordpress:
  volumes:
    - wp_data:/var/www/html
```

WordPress installs itself into `/var/www/html`. Since this folder is mapped to the volume `wp_data`, Docker copies the WordPress files into the volume the first time.

👉 Now the **`wp_data` volume contains the WordPress files**.

### 3. Nginx mounts the same volume

```yaml
nginx:
  volumes:
    - wp_data:/var/www/html:ro
```

Nginx doesn’t install anything there. It just mounts `wp_data` into `/var/www/html`. Since the volume already has WordPress, Nginx sees the same files.

`:ro` makes it **read-only** for Nginx, so it can serve files but not modify them.

---

## ✅ End Result

* **WordPress** writes/updates files (themes, plugins, uploads) into `/var/www/html`.
* **Nginx** reads the same files from `/var/www/html` when serving requests.

This way, both containers stay in sync with a single shared volume managed by Docker.
