FROM php:8.3-apache

# Installing system dependencies
RUN apt-get update && \
    apt-get install -y \
    sudo \
    git \
    unzip \
    nano \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    libpng-dev \
    default-mysql-client \
    ldap-utils \
    python3 \
    python3-pip \
    python3-venv \
    libldap2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    intl \
    exif \
    ldap \
    gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installing Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm@latest 

# Installing Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installing Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

RUN a2enmod rewrite headers
# COPY .devcontainer/apache.conf /etc/apache2/sites-available/000-default.conf

# RUN git clone https://github.com/loicdurand/accueil.git

# Create directories for Symfony
RUN mkdir -p /workspace/accueil/var/cache /workspace/accueil/var/log /workspace/accueil/var/log
RUN mkdir -p /workspace/resa/var/cache /workspace/resa/var/log /workspace/resa/var/log


# **************************
# * Create a non root user *
# **************************

ARG USERNAME=loic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Add user to sudo & www-data groups
    && usermod -aG sudo $USERNAME \
    && usermod -aG www-data $USERNAME

# Adding my aliases to the user's .bashrc
SHELL ["/bin/bash", "-c"]
RUN echo "alias ll='ls -alF'" >> /home/$USERNAME/.bashrc \
    && echo "alias la='ls -A'" >> /home/$USERNAME/.bashrc \
    && echo "alias l='ls -CF'" >> /home/$USERNAME/.bashrc \
    && echo "alias ..='cd ..'" >> /home/$USERNAME/.bashrc \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && cp /home/$USERNAME/.bashrc /root/ \
    && chown root:root /root/.bashrc \
    && chmod 644 /root/.bashrc \
    && source /home/$USERNAME/.bashrc

# Setting working directory
WORKDIR /workspace

# Setting permissions
RUN chown -R www-data:www-data /workspace /var/log/apache2 /etc/ssl/certs /etc/ssl/private \
    && chmod -R 775 /workspace /var/log/apache2 /etc/ssl/certs /etc/ssl/private

# Exposing ports for Apache
EXPOSE 80 443

# Start Apache in foreground
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
