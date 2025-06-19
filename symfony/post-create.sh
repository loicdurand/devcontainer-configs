#!/bin/bash

# Log output to a file for debugging
# exec &> /workspace/post-create.log

# Wait for MariaDB to be ready
MAX_ATTEMPTS=30
ATTEMPT=1
until mysql -h mysql -u root -proot symfony_db -e "SELECT 1" 2>/dev/null; do
    echo "Waiting for MariaDB to be ready... (Attempt $ATTEMPT/$MAX_ATTEMPTS)"
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
        echo "Error: MariaDB did not become ready in time. Exiting."
        exit 1
    fi
    sleep 2
    ((ATTEMPT++))
done
echo "MariaDB is ready!"

# Install Node.js dependencies
npm install || echo "Warning: npm install failed, continuing..."
echo "Node.js dependencies installed."

# Install PHP dependencies
composer install --no-interaction || echo "Warning: Composer install failed, continuing..."
echo "Composer dependencies installed."

# Clear Symfony cache
php bin/console cache:clear || echo "Warning: Cache clear failed, continuing..."
echo "Symfony cache cleared."

echo "Post-create setup completed at $(date)"
exit 0
