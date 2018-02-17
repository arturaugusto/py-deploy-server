#!/bin/bash
while [[ "$#" > 1 ]]; do case $1 in
    --port) port="$2";;
    *) break;;
  esac; shift; shift
done

mkdir -p ~/vassals
mkdir -p ~/vassals_log

mkdir -p ~/pyprojects


if [ ! -d ~/vassals/$port ]; then

  # Vassal conf 
  echo "[uwsgi]" > ~/vassals/$port.ini
  echo "module = wsgi" >> ~/vassals/$port.ini
  echo "master = true" >> ~/vassals/$port.ini
  echo "processes = 5" >> ~/vassals/$port.ini
  echo "socket = 127.0.0.1:$port " >> ~/vassals/$port.ini
  echo "chmod-socket = 660" >> ~/vassals/$port.ini
  echo "vacuum = true" >> ~/vassals/$port.ini
  echo "die-on-term = true" >> ~/vassals/$port.ini
  echo "chdir = /home/`logname`/pyprojects/$port" >> ~/vassals/$port.ini
  
  prevdir=`pwd`
  
  # Virtual env
  mkdir -p ~/pyprojects/$port
  cd ~/pyprojects/$port
  virtualenv venv
  source venv/bin/activate
  deactivate

  # Apache conf
  cd $prevdir
  echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/$port.conf
  echo "  ServerAdmin webmaster@localhost" >> /etc/apache2/sites-enabled/$port.conf
  echo "  ErrorLog /home/vassals_log/`logname`/$port.log" >> /etc/apache2/sites-enabled/$port.conf
  echo "  ServerName `hostname`" >> /etc/apache2/sites-enabled/$port.conf
  echo "  ProxyPass /$port uwsgi://127.0.0.1:$port/" >> /etc/apache2/sites-enabled/$port.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-enabled/$port.conf

  sudo apachectl -t
  sudo apachectl -k graceful

fi
