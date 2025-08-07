#!/bin/bash

echo "Starting post-create setup at $(date)"

# Utilisation de la version stable de Rust
rustup default stable

# Log output to a file for debugging
# exec &> /workspace/post-create.log
app="pwiz-gui"
for app in {"pwiz-gui","skoop"}; do
    
    # Check if the directory exists
    if [ -d "$app" ]; then

        echo "Installing $app node modules..."

        cd $app/src
        npm install

        # echo "Installing $app cargo crates..."

        # cd ../src-tauri
        # cargo build
        # cd ../..

        echo "'$app' website is ready!"
    else
         echo "Directory $app does not exist. Skipping setup for $app."
    fi

done

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

# cat << EOF
# When ready, serve the application with:
#     1. Open a terminal in the container, then `cd` into your Symfony project directory.
#     2. Run 'symfony serve --no-tls --listen-ip=0.0.0.0 -d' to start the Symfony server in detached mode.
#     3. Access your application at http://localhost:8000
#     4. To stop the server, run 'symfony server:stop'.
#     5. To restart the server, run 'symfony server:start'.

# EOF

# Changement du shell
/bin/bash

echo "Post-create setup completed at $(date)"
exit 0
