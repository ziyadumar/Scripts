#function to remove any previous version of docker - if exists
remove_old_docker()
{
echo removing old docker versions ...
sudo apt-get remove docker docker-engine docker.io containerd runc
}


#function for docker installation
docker()
{
echo installing docker, please wait ...
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

}

#function to install docker-compose
docker_compose()
{
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
}

#function for nginx server setup
nginx()
{
echo installing nginx, please wait ...
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get install python-certbot-nginx
}



#Main script starts here
echo 
"----------------Welcome Back, Fantacode!----------------"
echo -e "\n\tIt's nice to meet you"
echo May i suggest installing Docker CE and nginx on your server? [y/n]
read decision
if [ $decision == "Y" -o $decision == "y" ]; then
        {
        echo initiating server-setup sequence ...
	sudo apt-get update
        echo "Please wait while we install docker CE & docker-compose for you."
        echo Do you want to remove previous versions of docker? [y/n]
        read decision
        if [ $decision == "Y" -o $decision == "y" ]; then
                remove_old_docker
        else
                echo 'we will now install docker CE without removing previous docker versions'
        fi
        docker
	docker_compose
        nginx
	echo Do you want to configure nginx ?
	read decision
	if [ $decision == "Y" -o $decision == "y" ]; then
                bash ./nginx-config.sh
        else
                echo nginx will not be configured!
	fi
        }
else
        echo Alright, there is nothing more i can do for you!
        echo Bye
fi
echo setup finished!







