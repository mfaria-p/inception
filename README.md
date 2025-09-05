# 📦 Inception: WordPress + Nginx + MariaDB Docker Setup

## 📌 Overview
Custom containerized WordPress site using **Docker Compose** with three Alpine-based services:

- **Nginx** → HTTPS termination & reverse proxy  
- **WordPress** → PHP-FPM application with WP-CLI  
- **MariaDB** → Database backend  

---

## 🗂 Project Structure
```plaintext
project/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/              # SSL certificates
        ├── wordpress/
        │   ├── Dockerfile
        │   └── conf/wp-config-create.sh
        └── mariadb/
            ├── Dockerfile
            └── conf/
                ├── create_db.sh
                └── network.cnf
```

---

## 🚀 Quick Start

```bash
# Build and start
make build

# Stop services
make down

# Rebuild everything
make re

# Complete cleanup
make fclean
```

**Access:** https://mfaria-p.42.fr

---

## ⚙️ Architecture

```pgsql
         ┌──────────────────┐
         │   Web Browser    │
         │ (Host Machine)   │
         └───────▲──────────┘
                 │
         HTTP/HTTPS (80, 443)
                 │
         ┌───────┴──────────┐
         │     Nginx        │  ← Container
         │  (Reverse Proxy) │
         └───────▲──────────┘
                 │
      PHP-FPM (FastCGI)
                 │
         ┌───────┴──────────┐
         │   WordPress      │  ← Container
         │ (PHP-FPM app)    │
         └───────▲──────────┘
                 │
        MySQL Protocol (3306)
                 │
         ┌───────┴──────────┐
         │    MariaDB       │  ← Container
         │ (Database)       │
         └──────────────────┘
```

**Key Features:**
- 🔒 HTTPS-only with TLS 1.2/1.3
- 🐳 Custom Alpine images (no pre-built containers)
- 📁 Persistent data with bind mounts
- 🌐 Internal Docker networking

---

## 🔧 Services

### Nginx
- SSL termination & static file serving
- FastCGI proxy to WordPress container
- Custom configuration for WordPress

### WordPress  
- PHP 8.4 with PHP-FPM
- Automated setup with WP-CLI
- Database connection management

### MariaDB
- Custom initialization script
- Network configuration for container access
- Persistent database storage

---

## 🌐 Network Flow
1. Browser requests → go to **Nginx**.
2. Nginx forwards dynamic requests to **WordPress**.
3. WordPress fetches/saves data in **MariaDB**.
4. Responses flow back up to the browser.

All communication between containers happens inside a **private Docker network**, meaning only Nginx is exposed to the host.

---

## 📁 Data Persistence

```bash
# WordPress files
/home/${USER}/data/wordpress

# Database files  
/home/${USER}/data/mariadb
```

