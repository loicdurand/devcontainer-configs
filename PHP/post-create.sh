#!/bin/bash

echo "Starting post-create setup at $(date)"
cd /workspace/.devcontainer/

# Charger le fichier .env
if [ -f ".env" ]; then
    source .env
#   export $(grep -v '^#' .env | xargs)
else
  echo "Erreur : Fichier .env introuvable dans le répertoire courant."
  exit 1
fi

# Log output to a file for debugging
# exec &> /workspace/post-create.log
<<<<<<< HEAD
=======
cd /workspace/
>>>>>>> bdfe1ba9fb523768b692b88f1857004d03d503a2
app="vote"
# for app in {"accueil","resa","tomomi","vote"}; do
    # Check if the directory exists
    if [ -d "$app" ]; then
        # echo "Installing $app website dependancies..."

        cd /workspace/$app

        # Install Node.js + Composer dependencies
        # npm install || echo "Warning: npm install failed, continuing..."
        # echo "Node.js dependencies installed."
        # composer install --no-interaction || echo "Warning: Composer install failed, continuing..."
        # echo "Composer dependencies installed."

        # php bin/console secrets:set APP_SECRET || echo "Warning: Setting APP_SECRET failed, continuing..."
        # DATABASE_URL="mysql://root:${MYSQL_PASSWORD}@mysql:3306/$app?serverVersion=8.0.32&charset=utf8mb4"
        # composer dump-env dev

        # Set up 'accueil' database
<<<<<<< HEAD
        # mysql -h mysql -u root -pmy_password -e "\
        #     CREATE DATABASE IF NOT EXISTS $app;
        #     GRANT ALL PRIVILEGES ON $app.* TO admin IDENTIFIED BY 'my_password';\
        #     " 2>/dev/null
=======
        mysql -h mysql -u root -p$MYSQL_PASSWORD -e "\
            CREATE DATABASE IF NOT EXISTS $app;
            GRANT ALL PRIVILEGES ON $app.* TO $MYSQL_USER IDENTIFIED BY '$MYSQL_PASSWORD';\
            " 2>/dev/null
>>>>>>> bdfe1ba9fb523768b692b88f1857004d03d503a2
        # php bin/console doctrine:migrations:migrate --no-interaction || echo "Warning: Migrations failed, continuing..."
        # php bin/console doctrine:fixtures:load --no-interaction || echo "Warning: Fixtures load failed, continuing..."
        echo "Database '$app' is ready!"

        # Clear Symfony cache
        php bin/console cache:clear || echo "Warning: Cache clear failed, continuing..."
        # echo "Symfony cache cleared."
        # npm run dev || echo "Warning: npm run dev failed, continuing..."

        echo "'$app' website is ready!"
        cd /workspace
<<<<<<< HEAD
        
=======

>>>>>>> bdfe1ba9fb523768b692b88f1857004d03d503a2
    else
        echo "Directory $app does not exist. Skipping setup for $app."
    fi
# done
<<<<<<< HEAD

python3 -m venv ./python_venv
cd python_venv
./bin/pip3 install flask ldap3 python-jose[cryptography]
cd /workspace
=======
>>>>>>> bdfe1ba9fb523768b692b88f1857004d03d503a2

# Wait for MariaDB to be ready
# echo "DB connection check: mysql -h mysql -u mariadb -pmariadb -e 'SELECT 1'"
# MAX_ATTEMPTS=30
# ATTEMPT=1
# until mysql -h mysql -u mariadb -pmariadb mariadb -e "SELECT 1" 2>/dev/null; do
#     echo "Waiting for MariaDB to be ready... (Attempt $ATTEMPT/$MAX_ATTEMPTS)"
#     if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
#         echo "Error: MariaDB did not become ready in time. Exiting."
#         exit 1
#     fi
#     sleep 2
#     ((ATTEMPT++))
# done
# echo "MariaDB is ready!"

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
