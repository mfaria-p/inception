# 📦 Inception: WordPress + Nginx + MariaDB Docker Setup 

## 📌 Overview
This project sets up a fully containerized WordPress site using **Docker Compose**, with three main services:

- **Nginx** → Reverse proxy & HTTPS handler
- **WordPress** → PHP-FPM application
- **MariaDB** → Database backend

Each service runs in its own container and communicates via a private Docker network.

---

## 🗂 Project Structure
```plaintext
project/
└── srcs/
    ├── docker-compose.yml           # Docker services definition
    ├── .env                          # Environment variables
    ├── requirements/
    │   ├── nginx/                    # Nginx config & Dockerfile
    │   ├── wordpress/                # WordPress config & Dockerfile
    │   └── mariadb/                  # MariaDB config & Dockerfile
```
---

## ⚙️ How It Works
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

My stack has three main containers:

### Nginx

* Serves HTML, CSS, images, and static assets.
* Passes PHP requests to WordPress (via PHP-FPM).

### WordPress (PHP-FPM)

* Contains the WordPress source code.
* Executes PHP files (e.g., `index.php`, `wp-login.php`).
* Talks to the database to fetch content.

### Database (MariaDB/MySQL)

* Stores WordPress data (users, posts, comments, settings).
* WordPress connects with credentials defined in `wp-config.php`.

---

## 🔍 Service Roles
- **Nginx**
  - Listens on ports **80** (HTTP) and **443** (HTTPS)
  - Serves static content
  - Forwards PHP requests to the WordPress container

- **WordPress**
  - Runs on PHP-FPM
  - Handles dynamic content and business logic
  - Connects to MariaDB to read/write site data

- **MariaDB**
  - Stores all WordPress data (posts, users, settings)
  - Secured with credentials from `.env`

---

## 🌐 Network Flow
1. Browser requests → go to **Nginx**.
2. Nginx forwards dynamic requests to **WordPress**.
3. WordPress fetches/saves data in **MariaDB**.
4. Responses flow back up to the browser.

All communication between containers happens inside a **private Docker network**, meaning only Nginx is exposed to the host.

---

## 🚀 Running the Project
```bash
docker compose up --build
```
