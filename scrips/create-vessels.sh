#!/bin/bash
while [[ "$#" > 1 ]]; do case $1 in
    --port) port="$2";;
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
  virtualenv -p python3 venv
  source venv/bin/activate
  deactivate

  # apache proxy conf
  echo "ProxyPass /$port uwsgi://127.0.0.1:$port/" >> /etc/apache2/vassals.conf
  # remove possible duplicates
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' /etc/apache2/vassals.conf
  
  sudo apachectl -t
  sudo apachectl -k graceful

  cd $prevdir
fi
