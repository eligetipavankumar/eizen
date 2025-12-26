#!/bin/bash

# Task 2: Docker Compose Setup and Bring Up Service

set -e

echo "================================"
echo "Docker Compose Setup"
echo "================================"

REPO_URL="https://github.com/matdoering/minimal-flask-example"
REPO_NAME="minimal-flask-example"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed."
    exit 1
fi

# Clone the Flask repository
if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning Flask application repository..."
    git clone "$REPO_URL" "$REPO_NAME"
else
    echo "Repository already exists. Updating..."
    cd "$REPO_NAME"
    git pull
    cd ..
fi

# Create nginx configuration directory
echo "Setting up Nginx configuration..."
mkdir -p nginx/conf.d
mkdir -p nginx/logs
mkdir -p nginx/ssl

# Copy nginx configuration files
echo "Copying Nginx configuration files..."
# Files should be in the same directory as docker-compose.yml

# Build and start containers
echo "Building Docker images..."
docker-compose build

echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Check service status
echo ""
echo "Service Status:"
docker-compose ps

# Display access information
echo ""
echo "================================"
echo "Service Information"
echo "================================"
echo "Flask Application (internal): http://flask-app:5000"
echo "Nginx Proxy (external): http://localhost"
echo "Nginx Logs: ./nginx/logs/"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop services:"
echo "  docker-compose down"
echo ""
echo "To view access logs:"
echo "  tail -f nginx/logs/access.log"
echo ""
echo "To view JSON access logs:"
echo "  tail -f nginx/logs/access.json.log | jq ."
echo ""
