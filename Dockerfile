FROM php:8.3-apache

WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
        libicu-dev \
        libxml2-dev \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        zip \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Composer files first so dependency installation can be cached
COPY composer.json ./

RUN composer install \
        --no-dev \
        --prefer-dist \
        --no-interaction \
        --optimize-autoloader

# Copy application source after Composer
COPY . /var/www/html

RUN mkdir -p \
        storage/framework/cache \
        storage/framework/sessions \
        storage/framework/views \
        storage/logs \
        bootstrap/cache

RUN chown -R www-data:www-data \
        storage \
        bootstrap/cache

COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]
