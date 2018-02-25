from flask import Flask
from flask import request
import json
application = Flask(__name__)

def get_port(name):
  with open('/etc/apache2/vassals.conf', 'r') as f:
    cfg = f.read()
  cfg_lines = cfg.split('\n')
  used_ports = []
  for l in cfg_lines:
    if 'ProxyPass' in l:
      port = l.split(':')[-1][:-1]
      if ('/' + name + ' ') in l:
        return port
      used_ports.append(int(port))
  next_port = max(used_ports) + 1
  return next_port

@application.route("/", methods=['POST'])
def hello():
  git = request.json['repository']['clone_url']
  name = 'gh_' + (request.json['repository']['clone_url'].replace('/', '_'))
  port = get_port(name)
  # TODO: Execute script send parameters
  # with a sudo user that don't require password
  return 'Ok'

if __name__ == "__main__":
  application.run(host='0.0.0.0')
