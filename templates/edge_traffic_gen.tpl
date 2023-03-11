#! /bin/bash
# Update packages
sudo apt update -y
sudo apt -y install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo apt-get install sshpass -y
sudo apt-get install cron -y
sudo apt-get install nginx -y

# Traffic gen
cat <<SCR >>/home/ubuntu/cron.sh
#!/bin/bash
for i in \$(echo ${apps}|tr "," "\n"); do echo -e "22" | xargs -i sudo nc -w 1 -vn \$i {}; echo "\$(date): netcat \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo ping -c 4 \$i; echo "\$(date): ping \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:30013; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:30015; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:30017; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:30030; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:30032; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:30041; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:443; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:5000; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:514; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:3306; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:1433; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
for i in \$(echo ${apps}|tr "," "\n"); do sudo curl --insecure -m 1 http://\$i:8443; echo "\$(date): curl \$i" | sudo tee -a /var/log/traffic-gen.log; done
SCR

chmod +x /home/ubuntu/cron.sh

sudo crontab<<CRN
*/${interval} * * * * /home/ubuntu/cron.sh
0 10 * * * rm -f /var/log/traffic-gen.log
CRN
sudo systemctl restart cron

sudo bash -c " 
echo 'server {
    listen 80;
    listen 443;

    error_page    500 502 503 504  /50x.html;

    location      / {
        root      html;
    }

}' > /etc/nginx/conf.d/default.conf"

sudo service nginx restart
