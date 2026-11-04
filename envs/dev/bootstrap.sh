#!/bin/bash
# Amorcage minimal : nginx + une page portant le nom de l'hote
apt-get update -y
apt-get install -y nginx
echo "<h1>NovaSphere</h1><p>Hote : $(hostname)</p>" > /var/www/html/index.html
systemctl enable --now nginx
