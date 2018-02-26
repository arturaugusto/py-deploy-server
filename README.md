# py-deploy-server
[WIP]
Scripts to create a server capable of auto deploying python web applications through HTTPS.

The final solution uses the following softwares/technologies:

- Let’s Encrypt: https://letsencrypt.org/
- HAProxy: http://www.haproxy.org/
- Apache: https://httpd.apache.org/ with modules:
  - mod_proxy_uwsgi: https://uwsgi-docs.readthedocs.io/en/latest/Apache.html
  - mod_proxy: http://httpd.apache.org/docs/current/mod/mod_proxy.html
- Certbot: https://certbot.eff.org/
- Virtualenv: https://pypi.python.org/pypi/virtualenv

Prerequisites: A domain name and a GNU/Linux box with a sudo user capable of running commands without password:
https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart
https://askubuntu.com/questions/168461/how-do-i-sudo-without-having-to-enter-my-password#168470


references:

1. https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-uwsgi-and-nginx-on-ubuntu-14-04
1. https://mitchjacksontech.github.io/How-To-Flask-Python-Centos7-Apache-uWSGI/
1. https://www.digitalocean.com/community/tutorials/how-to-secure-haproxy-with-let-s-encrypt-on-ubuntu-14-04
1. https://uwsgi-docs.readthedocs.io/en/latest/Apache.html#mod-proxy-uwsgi