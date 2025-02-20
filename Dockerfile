# Use Ubuntu as the base image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install required dependencies
RUN apt update && apt install -y \
    software-properties-common \
    lsb-release \
    ca-certificates \
    curl

# Add the ondrej/php PPA for PHP 8.2
RUN add-apt-repository ppa:ondrej/php -y && apt update

# Install PHP 8.2 and necessary extensions
RUN apt install -y \
    nginx \
    git \
    unzip \
    php8.2 php8.2-fpm php8.2-cli \
    php8.2-mbstring php8.2-xml php8.2-bcmath \
    php8.2-curl php8.2-zip php8.2-tokenizer \
    php8.2-common php8.2-gd php8.2-mysql \
    php8.2-intl \
    npm && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Ensure the directory is empty before cloning
RUN rm -rf /var/www/html/*

# Clone the Laravel project
RUN git clone https://github.com/dhulkii/php-project-with-docker-github-actions.git . 

#RUN cd php-project-with-docker-github-actions

#RUN mv * /var/www/html/

#RUN mv .editorconfig  .env.example  .git  .gitattributes  .github  .gitignore  .gitmodules /var/www/html/


# Copy custom environment file
COPY .env /var/www/html/.env

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node.js dependencies and build frontend assets
RUN npm install && npm run dev

# Set permissions for SQLite database
RUN touch ./database/database.sqlite && chmod 666 ./database/database.sqlite

# Generate Laravel application key and run migrations
RUN php artisan key:generate && php artisan migrate --force && php artisan db:seed --force

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Expose the ports
EXPOSE 80 3306

# Start services
CMD service nginx start && php-fpm8.2 -F
