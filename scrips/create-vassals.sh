#!/bin/bash
while [[ "$#" > 1 ]]; do case $1 in
    --port) port="$2";;
    --git) git="$2";;
    --name) name="$2";;
    *) break;;
  esac; shift; shift
done

mkdir -p ~/vassals

mkdir -p ~/pyprojects

echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/000-default.conf
echo "  ServerAdmin webmaster@localhost" >> /etc/apache2/sites-enabled/000-default.conf
echo "  ErrorLog /home/`logname`/apache_error.log" >> /etc/apache2/sites-enabled/000-default.conf
echo "  Include vassals.conf" >> /etc/apache2/sites-enabled/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf

if [ ! -d ~/vassals/$port ]; then
    
  # Virtual env
  mkdir -p ~/pyprojects/$port
  cd ~/pyprojects/$port
  virtualenv -p python3 env

  # app
  mkdir -p ~/pyprojects/$port/app

  # Vassal conf 
  echo "[uwsgi]" > ~/vassals/$port.ini
  echo "module = wsgi" >> ~/vassals/$port.ini
  echo "master = true" >> ~/vassals/$port.ini
  echo "processes = 5" >> ~/vassals/$port.ini
  echo "socket = 127.0.0.1:$port " >> ~/vassals/$port.ini
  echo "chmod-socket = 660" >> ~/vassals/$port.ini
  echo "vacuum = true" >> ~/vassals/$port.ini
  echo "die-on-term = true" >> ~/vassals/$port.ini
  echo "chdir = /home/`logname`/pyprojects/$port/app" >> ~/vassals/$port.ini
  echo "virtualenv = /home/`logname`/pyprojects/$port/env"
  echo "logger = file:/home/`logname`/pyprojects/$port/uwsgi.log"
  echo "binary-path = home/`logname`/pyprojects/$port/env/bin/uwsgi"

  # apache proxy conf
  echo "ProxyPass /$name uwsgi://127.0.0.1:$port/" >> /etc/apache2/vassals.conf
  # remove possible duplicates
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' /etc/apache2/vassals.conf
  
  sudo apachectl -t
  sudo apachectl -k graceful

  # clone repository to path
  git clone $git ~/pyprojects/$port/app


fi

sudo chown -R `logname` ~/pyprojects/$port/
sudo chgrp -R `logname` ~/pyprojects/$port/

# update local app
cd ~/pyprojects/$port/app
git pull origin master

source ~/pyprojects/$port/env/bin/activate
~/pyprojects/$port/env/bin/pip3 install -r ~/pyprojects/$port/app/requirements.txt
deactivate

# refresh app
sudo touch --no-dereference ~/vassals/$port.ini

