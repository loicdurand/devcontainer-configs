#!/bin/bash

echo "Starting post-create setup at $(date)"

# Log output to a file for debugging
# exec &> /workspace/post-create.log

# Wait for MariaDB to be ready
echo "DB connection check: mysql -h mysql -u mariadb -pmariadb -e 'SELECT 1'"
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

for app in {"accueil","resa"}; do
    # Check if the directory exists
    if [ -d "$app" ]; then
        echo "Installing $app website dependancies..."

        cd $app

        # Install Node.js + Composer dependencies
        npm install || echo "Warning: npm install failed, continuing..."
        echo "Node.js dependencies installed."
        composer install --no-interaction || echo "Warning: Composer install failed, continuing..."
        echo "Composer dependencies installed."

        #php bin/console secrets:set APP_SECRET || echo "Warning: Setting APP_SECRET failed, continuing..."
        DATABASE_URL="mysql://root:mariadb@mysql:3306/$app?serverVersion=8.0.32&charset=utf8mb4"
        composer dump-env dev

        # Set up 'accueil' database
        mysql -h mysql -u root -pmariadb -e "\
            CREATE DATABASE $app;
            GRANT ALL PRIVILEGES ON $app.* TO mariadb IDENTIFIED BY 'mariadb';\
            " 2>/dev/null
        php bin/console doctrine:migrations:migrate --no-interaction || echo "Warning: Migrations failed, continuing..."
        php bin/console doctrine:fixtures:load --no-interaction || echo "Warning: Fixtures load failed, continuing..."
        echo "Database 'accueil' is ready!"

        # Clear Symfony cache
        php bin/console cache:clear || echo "Warning: Cache clear failed, continuing..."
        echo "Symfony cache cleared."
        npm run dev || echo "Warning: npm run dev failed, continuing..."

        cd ..
        echo "'accueil' website is ready!"
    else
        echo "Directory $app does not exist. Skipping setup for $app."
    fi
done

cat << EOF
When ready, serve the application with:
    1. Open a terminal in the container, then `cd` into your Symfony project directory.
    2. Run 'symfony serve --no-tls --listen-ip=0.0.0.0 -d' to start the Symfony server in detached mode.
    3. Access your application at http://localhost:8000
    4. To stop the server, run 'symfony server:stop'.
    5. To restart the server, run 'symfony server:start'.

EOF

# Changement su shell
/bin/bash

echo "Post-create setup completed at $(date)"
exit 0
