#!/bin/bash
HOST_DOMAIN=$2
R_DOMAIN=$1
EMAIL=$3

mkdir /etc/nginx/sites-available && mkdir /etc/nginx/sites-enabled
sed -i '/http {/a \ \ \ \ include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf

printf "server {
    listen 80;
    server_name $HOST_DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    
    server_name $HOST_DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$HOST_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$HOST_DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    location / {
        proxy_pass $R_DOMAIN;
        include proxy_params;
        
        # Add these additional headers
        proxy_redirect off;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Server \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_hide_header X-Powered-By;
        
        # Buffer settings for better performance
        proxy_buffers 8 16k;
        proxy_buffer_size 32k;
    }
}" > /etc/nginx/sites-available/$HOST_DOMAIN
ln -s /etc/nginx/sites-available/$HOST_DOMAIN /etc/nginx/sites-enabled/

printf "proxy_set_header Host \$http_host; \
\nproxy_set_header X-Real-IP \$remote_addr; \
\nproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; \
\nproxy_set_header X-Forwarded-Proto \$scheme; \
\nproxy_ssl_server_name on; \
\nproxy_ssl_protocols TLSv1.2 TLSv1.3; \
\nproxy_ssl_verify off;" > /etc/nginx/proxy_params

certbot --nginx -d $HOST_DOMAIN --email $EMAIL --agree-tos --no-eff-email
certbot renew --dry-run

nginx -g "daemon off;"
