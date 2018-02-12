adduser serveradm
gpasswd -a serveradm sudo

add-apt-repository ppa:certbot/certbot
add-apt-repository ppa:vbernat/haproxy-1.6


apt-get update

apt-get install certbot haproxy apache2 python3 python3-dev python python-dev  libapache2-mod-proxy-uwsgi libapache2-mod-uwsgi

sudo pip install virtualenv
sudo pip3 install virtualenv
