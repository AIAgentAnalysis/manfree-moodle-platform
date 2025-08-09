# Official Moodle 4.0 - Manfree Technologies Institute
FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    git \
    unzip \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        zip \
        intl \
        soap \
        opcache \
        xsl

# Enable Apache modules
RUN a2enmod rewrite

# Configure PHP settings for Moodle
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle.ini

# Copy local Moodle source (no external dependencies)
WORKDIR /var/www/html
COPY moodle-source/ .

# Create version file for tracking
RUN echo "v4.5.6" > /var/www/html/MOODLE_VERSION

# Create moodledata directory
RUN mkdir -p /var/www/moodledata

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html /var/www/moodledata

# Copy startup script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]