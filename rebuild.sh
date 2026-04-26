#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Stopping and removing old containers ---"
sudo docker compose down

echo "--- Cleaning up unused image layers ---"
sudo docker image prune -f

echo "--- Building and starting the new container ---"
# --build ensures your entrypoint.sh changes are baked in
sudo docker compose up -d --build

echo "--- Done! ---"
echo "Container Status:"
sudo docker compose ps

