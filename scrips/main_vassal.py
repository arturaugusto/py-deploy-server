from flask import Flask
from flask import request
from flask import abort
import json
import hmac
import hashlib
from subprocess import call
from os.path import expanduser
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
  home = expanduser("~")
  with open(home+'/pyprojects/secret', 'rb') as f:
    pw = f.read().strip()

  secret = 'sha1=' + hmac.new(pw, request.get_data(), hashlib.sha1).hexdigest()
  x_hub_signature = request.headers.get('X-Hub-Signature')
  if not hmac.compare_digest(secret, x_hub_signature):
    #print('Failed to check secret.')
    abort(500)

  git = request.json['repository']['clone_url']
  name = 'gh_' + (request.json['repository']['full_name'].replace('/', '_'))
  port = get_port(name)
  call(['/usr/bin/sudo', './create-vassals.sh', '--port', str(port), '--git', git, '--name', name])
  return 'OK'

if __name__ == "__main__":
  application.run(host='0.0.0.0')
