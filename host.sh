#!/bin/bash
HOST_DOMAIN=$2
R_DOMAIN=$1
EMAIL=$3

mkdir /etc/nginx/sites-available && mkdir /etc/nginx/sites-enabled
sed -i '/http {/a \ \ \ \ include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf

printf "server {\n\tlisten 80; \
\n\tserver_name $HOST_DOMAIN; \
\n\treturn 301 https://\$server_name\$request_uri; \
\n}\n\nserver {\n\tlisten 443 ssl; \
\n\tlisten [::]:443 ssl; \
\n\n\tserver_name $HOST_DOMAIN; \
\n\n\tssl_certificate /etc/letsencrypt/live/$HOST_DOMAIN/fullchain.pem; \
\n\tssl_certificate_key /etc/letsencrypt/live/$HOST_DOMAIN/privkey.pem; \
\n\tinclude /etc/letsencrypt/options-ssl-nginx.conf; \
\n\tssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; \
\n\n\tlocation / {\n\t\tproxy_pass $R_DOMAIN; \
\n\t\tinclude proxy_params; \
\n\t}\n}" > /etc/nginx/sites-available/$HOST_DOMAIN
ln -s /etc/nginx/sites-available/$HOST_DOMAIN /etc/nginx/sites-enabled/

printf "proxy_set_header Host \$http_host; \
\nproxy_set_header X-Real-IP \$remote_addr; \
\nproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; \
\nproxy_set_header X-Forwarded-Proto \$scheme; \
\nproxy_ssl_server_name on; \
\nproxy_ssl_protocols TLSv1.2 TLSv1.3;" > /etc/nginx/proxy_params

certbot --nginx -d $HOST_DOMAIN --email $EMAIL --agree-tos --no-eff-email
certbot renew --dry-run

nginx -g "daemon off;"
