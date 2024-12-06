#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <redirect_url>"
  exit 1
fi

REDIRECT_URL="$1"

echo "Installing Nginx..."
sudo apt update && sudo apt install -y nginx

echo "Configuring Nginx to redirect to $REDIRECT_URL..."
NGINX_CONF="/etc/nginx/sites-available/default"

sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    return 301 $REDIRECT_URL\$request_uri;
}
EOF

echo "Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
  echo "Reloading Nginx..."
  sudo systemctl reload nginx
  echo "Nginx is now redirecting all requests to $REDIRECT_URL."
else
  echo "Nginx configuration test failed. Please check the configuration."
fi
