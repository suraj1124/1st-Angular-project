#!/bin/bash

NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP="/etc/nginx/nginx.conf.bak"

# Backup original
cp "$NGINX_CONF" "$BACKUP"

# Replace root path
sed -i 's|root\s*/usr/share/nginx/html;|root         /var/www/my-angular-project;|' "$NGINX_CONF"

# Test config
nginx -t

# Restart Nginx
systemctl restart nginx
