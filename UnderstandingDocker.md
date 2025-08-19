# 🐳 Understanding Docker

## 🔹 Docker Image vs Container

A **Docker image** is like a frozen snapshot (a blueprint) that contains everything needed to run an application:

- A minimal operating system (Alpine, Debian, Ubuntu, etc.)
- Installed programs (e.g., Nginx, PHP, MariaDB...)
- Configuration files
- Instructions on how to start the app

👉 Images are **read-only**. When you start a container, Docker creates a **writable layer** on top of the image.

Think of it like:
- 📀 **Image** = CD-ROM (unchanging, template)
- 💻 **Container** = computer using the CD, with a scratchpad for changes

### Visual Concept

```
+-------------------------+
|      Docker Image       |   <- Blueprint (read-only)
|  - Tiny OS (Alpine)     |
|  - App (Nginx)          |
|  - Config files         |
+-------------------------+
             |
             v
+-------------------------+
|     Docker Container    |   <- Running instance (writable)
|  - Image contents       |
|  - Writable layer       |
|  - Runtime changes      |
+-------------------------+
```

You can list your images with:

```bash
docker images
```

Example output:

```
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
nginx            stable    992e3b7be046   2 weeks ago     141MB
alpine           3.16      b3ddf1fa5595   3 months ago    5.5MB
wordpress        latest    e1f8c14b3c36   4 days ago      617MB
```

- **Repository** = name of the image (nginx, alpine, wordpress...)
- **Tag** = version (stable, latest, 3.16...)
- **Size** = how heavy the image is

---

## 🔹 Dockerfile (Building an Image)

A **Dockerfile** is a recipe that defines how to build your image.

Example: `Dockerfile` for an Nginx server

```dockerfile
FROM alpine:3.16          # base OS (tiny Linux distro)
RUN apk add --no-cache nginx   # install nginx
COPY ./config/ /etc/nginx/http.d/  # copy config files
CMD ["nginx", "-g", "daemon off;"] # start nginx in foreground
```

Then build the image:

```bash
docker build -t my-nginx .
```

And run a container:

```bash
docker run -p 80:80 my-nginx
```

---

## 🔹 docker-compose.yml (Running Multi-Container Apps)

A **docker-compose.yml** file is used to define and run multiple containers together.  
Instead of starting each container manually, you describe the setup once.

A `docker-compose.yml` file is a **configuration** that tells Docker:

1. **Which containers** you want to run  
   (e.g., web server, database, cache…)

2. **Which image** each container should use  
   - This can be:
     - A pre-built image from **Docker Hub** (e.g., `nginx:stable`, `mariadb:10.5`)  
     - A custom image built from your **Dockerfile** (e.g., `build: .`)  

3. **How they should connect to each other**  
   (via an internal Docker network so containers can talk by service name like `db` or `web`)

4. **What ports, volumes, and environment variables** to expose/set  

Example: `docker-compose.yml` for WordPress + MariaDB

```yaml
version: "3.9"
services:
  db:
    image: mariadb:10.5
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: wp_pass

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: wp_pass
      WORDPRESS_DB_NAME: wordpress
```

Run everything with:

```bash
docker-compose up
```
---

## ✅ TL;DR

- **Docker Image** = packaged app + environment (blueprint, static)
- **Docker Container** = running instance of an image (dynamic, can change)
- **Dockerfile** = defines *how to build* an image
- **docker-compose.yml** = defines *how to run* one or more containers, either from your images or public one
