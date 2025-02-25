# Laravel + Nginx + MySQL in a  Docker Container

This project sets up a Laravel application inside a single Docker container with **Nginx, PHP-FPM, and MySQL** using **Supervisor** to manage multiple services.

---

## 🚀 Features

- Ubuntu 24.04 as the base image
- Nginx as the web server
- PHP 8.2 with required extensions
- MySQL (MariaDB) database inside the same container
- Supervisor for managing multiple services
- Automatic Laravel setup (Composer install, NPM install, migrations, etc.)

---

## 📁 Folder Structure

```
php-docker-project/
│── Dockerfile
│── nginx.conf
│── supervisord.conf
│── .env (Custom Laravel environment file)
│── app/  (Laravel Project)
```

---

## 🛠️ Setup & Installation

### **1️⃣ Clone this repository**

```sh
git clone https://github.com/yourusername/php-docker-project.git
cd php-docker-project
```

### **2️⃣ Build the Docker image**

```sh
docker build -t php-nginx-mysql .
```

### **3️⃣ Run the container**

```sh
docker run -d -p 80:80 --name php_server php-nginx-mysql
```

### **4️⃣ Verify the setup**

- Visit [**http://localhost**](http://localhost) to see your Laravel app running.
- Check running processes:
  ```sh
  docker exec -it php_server supervisorctl status
  ```

---

## 🔧 Dockerfile Overview

This Dockerfile:

- Installs Nginx, PHP, MySQL, and required extensions.
- Installs Laravel dependencies (Composer & NPM packages).
- Sets up Laravel environment, runs migrations & seeds database.
- Uses Supervisor to manage Nginx, PHP-FPM, and MySQL processes.

```dockerfile

# Install required packages
RUN apt update && apt install -y \
    nginx php8.2 php8.2-fpm php8.2-mysql php8.2-cli php8.2-mbstring php8.2-xml \
    php8.2-bcmath php8.2-curl php8.2-zip php8.2-tokenizer php8.2-common php8.2-gd \
    php8.2-intl php8.2-sqlite3 php8.2-json mariadb-server unzip curl git npm supervisor

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Copy Laravel application
COPY app /var/www/html

# Set permissions
RUN chmod -R 777 storage bootstrap/cache

# Install Laravel dependencies
RUN composer install && npm install && npm run build

# Set up Laravel environment & database
RUN cp .env.example .env && php artisan key:generate
RUN touch ./database/database.sqlite && chmod 666 ./database/database.sqlite
RUN php artisan migrate --seed
```

---

## 🔄 Stopping & Removing the Container

```sh
docker stop php_server
docker rm php_server
docker rmi php-nginx-mysql
```

---

## 📜 License

This project is open-source under the MIT License.

