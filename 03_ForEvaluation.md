# Inception Project: A Comprehensive Guide

This document provides a detailed overview of the Inception project, including its core technologies, architecture, and a step-by-step guide for its evaluation.

## 1\. Project Overview

The Inception project is a multi-service web application built with **Docker** and **Docker Compose**. It consists of three primary services:

  * **WordPress**: The content management system (CMS) that provides the website's functionality. It runs on **PHP-FPM** (FastCGI Process Manager).
  * **MariaDB**: The database that stores all WordPress data, including posts, users, and settings.
  * **Nginx**: The web server and reverse proxy that handles incoming requests, serves the website, and enforces secure connections using **SSL/TLS**.

These services are linked together via a custom Docker network, ensuring secure and efficient communication.

### 1.1 How Docker and Docker Compose Work

**Docker** is a tool that packages applications and their dependencies into self-contained units called **containers**. A container is a lightweight, executable software package that includes everything needed to run an application.

**Docker Compose** is a tool for defining and running multi-container Docker applications. Instead of running each container separately with a `docker run` command, you define all your services in a single `docker-compose.yml` file. This file acts as a blueprint, allowing you to start and manage your entire application with a single command: `docker-compose up`.

### 1.2 Docker Benefits over VMs

| Feature | Docker Containers | Virtual Machines (VMs) |
| :--- | :--- | :--- |
| **Resource Usage** | **Lightweight** (shares host OS kernel) | **Heavyweight** (each has its own full OS) |
| **Startup Time** | **Seconds** | **Minutes** |
| **Portability** | Highly portable and small | Less portable and large (gigabytes) |
| **Security** | Process-level isolation | OS-level isolation |

Containers are far more efficient and faster than VMs, making them ideal for modern development and deployment workflows.

## 2\. Project Architecture and File Structure

### 2.1 Directory Structure

The project follows a best-practice directory structure for clarity and organization.

```bash
project/
└── srcs/
    ├── docker-compose.yml           # Docker services definition
    ├── .env                         # Environment variables
    ├── requirements/
    │   ├── nginx/                   # Nginx config & Dockerfile
    │   ├── wordpress/               # WordPress config & Dockerfile
    │   └── mariadb/                 # MariaDB config & Dockerfile
```

  * **`docker-compose.yml`**: Defines the services, volumes, and networks.
  * **`.env`**: Stores sensitive information like passwords and domain names as environment variables, keeping them separate from the public configuration.
  * **`requirements/`**: Contains subdirectories for each service, each with its own `Dockerfile` and configuration files.

### 2.2 Dockerfiles and Scripts

Each service has a `Dockerfile` that builds its image. Key features include:

  * **WordPress `Dockerfile`**: Uses a shell script (`wp-config-create.sh`) to automate the installation of WordPress and configure it based on environment variables. It also handles the installation of `WP-CLI` for command-line management.
  * **MariaDB `Dockerfile`**: Uses a script (`create_db.sh`) to securely initialize the database and create a user and database for WordPress.
  * **`daemon off;` / `exec ... -F`**: All services are configured to run in the **foreground**, which is crucial for Docker containers. When a container's main process (PID 1) exits, the container stops. Running the services in the foreground prevents them from becoming background daemons, ensuring the container remains active.

-----

## 3\. Evaluation Checklist and Commands

To verify the project's functionality, follow these steps.

### 3.1 Setup and Launch

1.  **SSH into the VM**:
    ```bash
    ssh mfaria-p@192.168.1.196 -p 4242
    ```
2.  **Clone the Repository and Copy `.env`**:
    ```bash
    git clone ...
    cp .env /home/mfaria-p/project/srcs
    ```
3.  **Launch the Services**:
    ```bash
    cd /home/mfaria-p/project/srcs
    docker compose up -d
    ```

### 3.2 Verification

#### **Container and Image Status**

  * **List running containers**:
    ```bash
    docker ps
    ```
  * **List images and verify names**:
    ```bash
    docker images
    ```
    *(The images should be named after their corresponding services, e.g., `srcs_wordpress`)*

#### **Network and Ports**

  * **Verify network exists**:
    ```bash
    docker network ls
    ```
    *(Look for `srcs_inception`)*
  * **Verify Nginx is accessible on port 443**:
      * Open `https://mfaria-p.42.fr` in your browser.
      * Verify the TLS certificate is valid and is using **TLS v1.2** or **TLS v1.3** by checking your browser's security settings.
  * **Verify HTTP (port 80) is not accessible**:
    ```bash
    curl -v http://mfaria-p.42.fr
    ```
    *(This should fail or redirect to HTTPS, as port 80 is not mapped)*

#### **Volumes and Data Persistence**

  * **List volumes**:
    ```bash
    docker volume ls
    ```
    *(Look for `srcs_wordpress_data` and `srcs_mariadb_data`)*
  * **Inspect a volume to check its path**:
    ```bash
    docker volume inspect srcs_wordpress_data
    ```
    *(The output's `"Options"` section should show `"device": "/home/mfaria-p/data/wordpress"`, confirming data persistence on the host machine)*

#### **Database Login and Content**

  * **Log in to the database from a container**:
    ```bash
    docker exec -it wordpress sh
    apk add --no-cache mariadb-client # only once
    mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
    ```
  * **Verify tables exist**:
    ```sql
    SHOW TABLES;
    ```
    *(The output should show a list of tables, confirming the database is not empty)*
  * **Inspect a table's data**:
    ```sql
    SELECT ID, user_login FROM wp_users;
    ```
    *(This confirms that the admin user was created correctly during the installation)*

#### **Reboot and Data Persistence Test**

  * **Reboot the VM**:
    ```bash
    sudo reboot
    ```
  * **After reboot, launch services and verify changes**:
    ```bash
    docker compose up -d
    ```
      * Revisit `https://mfaria-p.42.fr` to ensure the website is still configured and any previous changes you made (e.g., adding a post) are still there.

Here is an updated section for your README, including the commands to check if your hosts file has been updated with the domain.

-----

### 3.2.1 DNS and Host File Configuration

For my domain name (`mfaria-p.42.fr`) to correctly resolve to your virtual machine's IP address, the host's `/etc/hosts` file must be updated. This project automates this process. You can verify the configuration with the following commands:

  * **View the update script**:

    ```bash
    cat /usr/local/bin/update_hosts.sh
    ```

    *(This script is responsible for adding the domain to the hosts file.)*

  * **Check the `/etc/hosts` file directly**:

    ```bash
    cat /etc/hosts
    ```

    *(The output should show a line like `127.0.0.1 mfaria-p.42.fr`, or a similar entry that maps your domain to a loopback or local IP.)*

  * **Check the log file**:

    ```bash
    cat /var/log/update_hosts.log
    ```

    *(This file should contain a log of when the hosts file was last updated, confirming the script ran successfully.)*

  * **List the contents of the log directory**:

    ```bash
    ls -l /var/log
    ```

    *(This command confirms the existence of the `update_hosts.log` file itself.)*

These commands verify that the domain name is correctly configured on your VM, allowing you to access the website using the custom domain instead of just the IP address.

-----

### 3.3 Clean-up Commands

These commands are used to completely reset the Docker environment.

  * **Stop and remove all containers**:
    ```bash
    docker stop $(docker ps -qa) && docker rm $(docker ps -qa)
    ```
  * **Remove all images**:
    ```bash
    docker rmi -f $(docker images -qa)
    ```
  * **Remove all volumes**:
    ```bash
    docker volume rm $(docker volume ls -q)
    ```
  * **Remove all networks**:
    ```bash
    docker network rm $(docker network ls -q) 2>/dev/null
    ```
