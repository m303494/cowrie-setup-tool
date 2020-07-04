#/bin/bash

#Add Elastic's repository and key. Then, apt-get update
sudo wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update

#Install logstash, elasticsearch, kibana and filebeat
sudo apt -y install apt-transport-https wget default-jre curl
sudo apt install elasticsearch logstash kibana
sudo apt install filebeat
sudo apt install -y nginx apache2-utils

#Enable the services and start them
sudo systemctl enable elasticsearch logstash kibana filebeat nginx
sudo -i service elasticsearch start && sudo -i service logstash start && sudo -i service kibana start && sudo -i service filebeat start && sudo -i service nginx start

#Try elasticsearch on port 9200 (should get a JSON object in return)
curl http://localhost:9200

#Make folder for logs for Kibana
sudo mkdir /var/log/kibana
sudo chown kibana:kibana /var/log/kibana

#Change some important parameters on kibana.yml
sudo sed -i -e 's/#server.host: "localhost"/server.host: "localhost"/g' /etc/kibana/kibana.yml
sudo sed -i -e 's/#server.name: "your-hostname"/server.name: "svr04"/g' /etc/kibana/kibana.yml
sudo sed -i -e 's/#elasticsearch.hosts:/elasticsearch.hosts:/g' /etc/kibana/kibana.yml
sudo sed -i -e 's=#logging.dest: stdout=logging.dest: /var/log/kibana/kibana.log=g' /etc/kibana/kibana.yml

#Copy the cowrie configuration for logstash into its conf.d folder and restart the service
sudo cp /home/cowrie/cowrie/docs/elk/logstash-cowrie.conf /etc/logstash/conf.d
sudo systemctl restart logstash

#Copy the cowrie configuration for filebeat and change the user's name in the path. Then, restart the service
sudo cp /home/cowrie/cowrie/docs/elk/filebeat-cowrie.conf /etc/filebeat/filebeat.yml
sudo sed -i -e 's=/home/axelle/cowrie/var/log/cowrie/cowrie.json=/home/cowrie/cowrie/var/log/cowrie/cowrie.json=g' /etc/filebeat/filebeat.yml
sudo systemctl restart filebeat

#Install nginx and change password for admin_kibana user
sudo apt install nginx apache2-utils
echo "Input password for user admin_kibana"
sudo htpasswd -c /etc/nginx/htpasswd.users admin_kibana

#Change the default nginx configuration to fit our needs and restart the service
sudo sed -i -e 's=listen=#listen=g' /etc/nginx/sites-available/default
sudo sed -i -e 's=root=#root=g' /etc/nginx/sites-available/default
sudo sed -i -e 's=server_name _;=#server_name _;=g' /etc/nginx/sites-available/default
sudo sed -i -e 's\try_files $uri $uri/ =404;\proxy_pass http://localhost:5601;proxy_http_version 1.1;proxy_set_header Upgrade $http_upgrade;proxy_set_header Connection 'upgrade';proxy_set_header Host $host;proxy_cache_bypass $http_upgrade;\g' /etc/nginx/sites-available/default
sudo sed -i -e 's=#listen 80 default_server;=listen 80;server_name localhost;auth_basic "Restricted Access";auth_basic_user_file /etc/nginx/htpasswd.users;=g' /etc/nginx/sites-available/default
sudo systemctl restart nginx

#Echo some important information
echo "Kibana starting on localhost:80 (will take about 2-3 minutes)"
echo "username: admin_kibana"
echo "password: [user input]"
echo "After getting 'Kibana server is not ready yet', wait a minute and refresh the page."
echo "After the Kibana server is up and running, follow the rest of the instructions in the readme file"



