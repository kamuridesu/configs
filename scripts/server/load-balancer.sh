# /usr/bin/bash

sudo apt update && sudo apt update -y && sudo apt install haproxy curl certbot vim net-tools git -y
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 81 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save
sudo certbot certonly --standalone -d test.com --non-interactive --agree-tos --email
sudo mkdir -p /etc/ssl/com.test/
sudo cat /etc/letsencrypt/live/test.com/fullchain.pem /etc/letsencrypt/live/test.com/privkey.pem | sudo tee /etc/ssl/com.test/com.test.pem
sudo bash -c 'cat << EOF > /opt/update-certs.sh
#!/bin/bash

# Renew the certificate
certbot renew --force-renewal --pre-hook "service haproxy stop" --post-hook "service haproxy start"

# Concatenate new cert files, with less output (avoiding the use tee and its output to stdout)
bash -c "cat /etc/letsencrypt/live/test.com/fullchain.pem /etc/letsencrypt/live/test.com/privkey.pem > /etc/ssl/com.test/com.test.pem"

EOF'
cat /opt/update-certs.sh 
vim /etc/cron.d/certbot 
sudo vim /etc/cron.d/certbot 
sudo systemctl enable haproxy
sudo systemctl start haproxy
