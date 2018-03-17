sudo mkdir -p /home/$SUDO_USER/pyprojects
sudo mkdir -p /home/$SUDO_USER/vassals
sudo sed "s/{USER}/$SUDO_USER/g" ./template_files/uwsgi-emperor.service > /etc/systemd/system/uwsgi-emperor.service

sudo systemctl enable uwsgi-emperor
sudo systemctl start uwsgi-emperor

pwgen 8 1 > ~/pyprojects/secret
