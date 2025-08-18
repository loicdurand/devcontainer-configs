#!/bin/bash

app="skoop"

echo "Starting post-create setup at $(date)"

echo "Installing $app node modules..."

cd /src
npm install
echo "$app website is ready!"

echo "Post-create setup completed at $(date)"
exit 0
