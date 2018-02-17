sudo sed "s/{USER}/`logname`/g" ./template_files/uwsgi-emperor.service > /etc/init/uwsgi-emperor.service

sudo systemctl enable uwsgi-emperor
sudo systemctl start uwsgi-emperor
