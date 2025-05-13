# Use the official PHP image as the base
FROM php:8.4-fpm

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    # PostgreSQL dev libraries
    libpq-dev \
    # Make sure these are installed
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer.json and composer.lock to the container
COPY composer.json composer.lock* ./

# Update composer

RUN composer update

# Install project dependencies
RUN composer install --no-scripts --no-autoloader

# Copy the rest of the application code to the container
COPY . .

# Copy Caddyfile to destination
COPY ./caddy/Caddyfile /etc/caddy/Caddyfile

# Set permissions for Laravel storage and bootstrap cache folders
RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache

# Expose port 9000
EXPOSE 9000

# Start the PHP-FPM server
CMD ["php-fpm"]