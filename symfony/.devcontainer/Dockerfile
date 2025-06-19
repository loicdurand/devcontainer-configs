FROM php:8.2-fpm

# Installing system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    && docker-php-ext-install \
    pdo_mysql \
    default-mysql-client \
    zip \
    intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install php-mysql driver + php-extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql mbstring gd intl

# Installing Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installing Node.js and NPM
# RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
#     && apt-get install -y nodejs \
#     && npm install -g npm@latest \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# Setting working directory
WORKDIR /workspace

# Installing Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Exposing port for Symfony dev server
EXPOSE 8000