#!/bin/bash

echo "Starting post-create setup at $(date)"

# Log output to a file for debugging
# exec &> /workspace/post-create.log

# Wait for MariaDB to be ready
echo "DB connection check: mysql -h mysql -u mariadb -pmariadb mariadb -e 'SELECT 1'"
MAX_ATTEMPTS=30
ATTEMPT=1
until mysql -h mysql -u mariadb -pmariadb mariadb -e "SELECT 1" 2>/dev/null; do
    echo "Waiting for MariaDB to be ready... (Attempt $ATTEMPT/$MAX_ATTEMPTS)"
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
        echo "Error: MariaDB did not become ready in time. Exiting."
        exit 1
    fi
    sleep 2
    ((ATTEMPT++))
done
echo "MariaDB is ready!"

# Adding the "accueil" website
echo "Installing 'accueil' website dependancies..."

cd accueil

# Install Node.js dependencies
npm install || echo "Warning: npm install failed, continuing..."
echo "Node.js dependencies installed."

# Install PHP dependencies
composer install --no-interaction || echo "Warning: Composer install failed, continuing..."
echo "Composer dependencies installed."

#php bin/console secrets:set APP_SECRET || echo "Warning: Setting APP_SECRET failed, continuing..."

# composer require symfony/runtime || echo "Warning: Composer require symfony/runtime failed, continuing..."
# composer install --no-interaction || echo "Warning: Composer install failed, continuing..."
composer dump-env dev

# Set up 'accueil' database
mysql -h mysql -u root -pmariadb -e "\
    CREATE DATABASE accueil;
    GRANT ALL PRIVILEGES ON accueil.* TO mariadb IDENTIFIED BY 'mariadb';\
    " 2>/dev/null
php bin/console doctrine:migrations:migrate --no-interaction || echo "Warning: Migrations failed, continuing..."
php bin/console doctrine:fixtures:load --no-interaction || echo "Warning: Fixtures load failed, continuing..."
echo "Database 'accueil' is ready!"

# Clear Symfony cache
php bin/console cache:clear || echo "Warning: Cache clear failed, continuing..."
echo "Symfony cache cleared."
npm run dev || echo "Warning: npm run dev failed, continuing..."
symfony serve --no-tls --listen-ip=0.0.0.0 -d || echo "Warning: Symfony server start failed, continuing..."

cd ..
echo "'accueil' website is ready!"

# apache2ctl restart

cat << EOF
If you are building a traditional web application:
    1. Open a terminal in the container.
    2. Run 'symfony new --webapp my_project' to create a new Symfony project."

If you are building a headless API application:"
    1. Open a terminal in the container."
    2. Run 'symfony new my_project' to create a new Symfony project."

When ready, serve the application with:
    1. Open a terminal in the container.
    2. Run 'symfony serve --no-tls --listen-ip=0.0.0.0 -d' to start the Symfony server in detached mode.
    3. Access your application at http://localhost:8000
    4. To stop the server, run 'symfony server:stop'.
    5. To restart the server, run 'symfony server:start'.

EOF

# Changement su shell
/bin/bash

echo "Post-create setup completed at $(date)"
exit 0
