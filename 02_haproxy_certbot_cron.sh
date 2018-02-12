DOMAIN='example.com'
IP_ADDR='123.456.789.10'

# use admin user

su - serveradm

cp ./template_files/haproxy.cfg ./haproxy.cfg
cp ./template_files/renew.sh ./renew.sh

# ensure haproxy is stopped
#netstat -na | grep ':80.*LISTEN'

sudo certbot certonly --standalone --preferred-challenges http --http-01-port 80 -d example.com -d www.example.com

sudo ls /etc/letsencrypt/live/example.com

sudo mkdir -p /etc/haproxy/certs


sudo -E bash -c 'cat /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem > /etc/haproxy/certs/$DOMAIN.pem'

sudo chmod -R go-rwx /etc/haproxy/certs

# copy haproxy.cfg with correct domain and ip addr

sed -i "s/{domain_name}/$DOMAIN/g" haproxy.cfg
sed -i "s/{ip_addr}/$IP_ADDR/g" haproxy.cfg

sudo cat haproxy.cfg > /etc/haproxy/haproxy.cfg

# copy renew scripts
sed -i "s/{domain_name}/$DOMAIN/g" renew.sh
sudo cp renew.sh /usr/local/bin/renew.sh

sudo chmod u+x /usr/local/bin/renew.sh

#sudo /usr/local/bin/renew.sh

# change http01_port
sudo sed -i 's/http01_port = 80/http01_port = 54321/g' /etc/letsencrypt/renewal/$DOMAIN.conf

sudo certbot renew --dry-run

# Create a Cron Job to renew certs

#sudo crontab -e

# write out current crontab, excluding certbot entries to avoid duplicates
sudo crontab -l | grep -v certbot > mycron
# echo new cron into cron file
sudo echo "30 2 * * * /usr/bin/certbot renew --renew-hook \"/usr/local/bin/renew.sh\" >> /var/log/le-renewal.log
" >> mycron
# install new cron file
sudo crontab mycron
sudo rm mycron

