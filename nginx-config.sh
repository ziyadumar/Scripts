echo What is the name of your app? \( File will be created with this name \)
read appname
rm /etc/nginx/sites-available/$appname

touch /etc/nginx/sites-available/$appname
rm /etc/nginx/sites-enabled/$appname

echo What is your Server Name? \( domain \)
read servername
echo Port specified?
read portnum
echo -e "server { \n    server_name  $servername; \n    location / { \n        proxy_pass         http://localhost:$portnum; \n        proxy_http_version 1.1; \n        proxy_set_header   Connection keep-alive; \n        proxy_set_header   Host \$host; \n        proxy_cache_bypass \$http_upgrade; \n        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for; \n         proxy_set_header   X-Forwarded-Proto \$scheme; \n    } \n}" >>  /etc/nginx/sites-available/$appname
ln -s /etc/nginx/sites-available/$appname /etc/nginx/sites-enabled/
sudo certbot --nginx -d $servername
sudo nginx -t
sudo systemctl reload nginx
echo nginx configuration completed for $appname!
