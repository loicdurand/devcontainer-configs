FROM php:8.2-fpm

# Installing system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    unzip \
    nano \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    default-mysql-client
RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    intl \
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

# **************************
# * Create a non root user *
# **************************

ARG USERNAME=loic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
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
RUN chown -R www-data:www-data /workspace
RUN chmod -R 775 /workspace

# Exposing port for Symfony dev server
EXPOSE 8000