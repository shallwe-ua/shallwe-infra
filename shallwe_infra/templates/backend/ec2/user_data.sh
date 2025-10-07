#!/bin/bash

# Allocate swap
sudo fallocate -l 2G /swapfile || { echo "Error: fallocate failed"; exit 1; }
sudo chmod 600 /swapfile || { echo "Error: chmod failed"; exit 1; }
sudo mkswap /swapfile || { echo "Error: mkswap failed"; exit 1; }
sudo swapon /swapfile || { echo "Error: swapon failed"; exit 1; }
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab || { echo "Error: fstab update failed"; exit 1; }

# Set env vars for ecs agent
echo ECS_CLUSTER=${SHALLWE_AWS_BACKEND_ECS_CLUSTER_NAME} >> /etc/ecs/ecs.config;
echo ECS_BACKEND_HOST=https://ecs.${SHALLWE_AWS_REGION}.amazonaws.com >> /etc/ecs/ecs.config;
