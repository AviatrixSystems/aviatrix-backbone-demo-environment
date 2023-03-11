#! /bin/bash
sudo hostnamectl set-hostname ${name}
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# Add workload user
sudo adduser workload
sudo echo "workload:${password}" | sudo /usr/sbin/chpasswd
sudo sed -i'' -e 's+\%sudo.*+\%sudo  ALL=(ALL) NOPASSWD: ALL+g' /etc/sudoers
sudo usermod -aG sudo workload
sudo service sshd restart
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Update packages
sudo apt update -y
sudo apt -y install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo apt-get install sshpass -y
sudo apt-get install cron -y
sudo apt-get install nginx -y

# SAP mock
echo "server {
    listen 80;
    listen 443;
    listen 30013;
    listen 30015;
    listen 30017;
    listen 30030;
    listen 30032;
    listen 30041;

    error_page    500 502 503 504  /50x.html;

    location      / {
        root      html;
    }

}" > /etc/nginx/conf.d/default.conf

sudo service nginx restart
