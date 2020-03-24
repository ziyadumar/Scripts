echo "This process *requires a domain, continue [y/n] "
read decision
if [ $decision == "N" -o $decision == "n" ]; then
        {
        exit 1
        }
fi

echo Do you want to create a new instance?
read decision
if [ $decision == "Y" -o $decision == "y" ]; then
	{
	echo Initiating instance-creation sequence . . . . .
	# read instance name
	echo What would you name the new instance?
	read name
	
	echo Provide port number specified to map
	read port
	#keep instance registry
	
	#create instance specific docker file 
	#append the name to the filename
	rm docker-compose-$name.yml
	touch docker-compose-$name.yml
	echo -e "version: \"3.4\"

services:
  pgservice:
    image: asia.gcr.io/fantacode-services/deliapp-pgservice:latest
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    restart: always
    container_name: ${name}-pgservice
    environment:
      - POSTGRES_PASSWORD=root
    volumes:
      - pgdata:/var/lib/postgresql/data
  deliveryapp:
    image: asia.gcr.io/fantacode-services/deliappweb:latest
    container_name: ${name}-web
    environment:
      - PgSqlConnectionString=Server=pgservice;Database=DeliveryAppDB;User Id=postgres;Password=root;Integrated Security=true;;
      - TokenIssuer=DeliveryAppAPIAuthorizationServer
      - JwtTokenAudience=DeliveryAppAPIConsumers
      - JwtSecretToken=9m99YvbUoLnz5nFkh5uz7XGxt3ZTMiXWLi95ufy7ZjrP9aIaXmfMysqurDHmmpe47DhTWZUThdaP7RzgD8AsoDwXbMGeGQclBD5pYzDBuvPKyhjA3wLtJszgBQfg0txv
      - APIKey=fxpkKly1laDAGytUUrnBKLhTjNNhgNWfIZfeGfItP4RueGg8
      - HangfireServerConnectionString=Server=pgservice;Database=DeliveryAppHangfireDB;User Id=postgres;Password=root;Integrated Security=true;
      - SMSGatewayAuthIN=YOUR-MSG91-KEY-HERE
      - HangfireDashboardAuth=true
      - BaseUrl=https://delivery.kooz.top/
      - APIKeyEnabled=false
      - RazorPayKey=YOUR-RAZORPAY-KEY-HERE
      - RazorPaySecret=YOUR-RAZORPAY-SECRET-HERE
      - Environment=development
    ports:
      - ${port}:80
    depends_on:
      - pgservice
volumes:
  pgdata:
    driver: local" >> docker-compose-$name.yml

	docker-compose -f docker-compose-$name.yml pull
	docker-compose -f docker-compose-$name.yml up -d
	
	echo -e "\n Configuring Nginx . . .  \n"
	rm /etc/nginx/sites-available/$name

	touch /etc/nginx/sites-available/$name
	rm /etc/nginx/sites-enabled/$name

	echo What is your Server Name? \( domain \)
	read servername
	echo -e "server { \n    server_name  $servername; \n    location / { \n        proxy_pass         http://localhost:$port; \n        proxy_http_version 1.1; \n        proxy_set_header   Connection keep-alive; \n        proxy_set_header   Host \$host; \n        proxy_cache_bypass \$http_upgrade; \n        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for; \n         proxy_set_header   X-Forwarded-Proto \$scheme; \n    } \n}" >>  /etc/nginx/sites-available/$name
	ln -s /etc/nginx/sites-available/$name /etc/nginx/sites-enabled/
	sudo certbot --nginx -d $servername
	sudo nginx -t
	sudo systemctl reload nginx
	echo nginx configuration completed for $name!


	}
fi
