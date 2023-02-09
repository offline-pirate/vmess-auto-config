echo 'create direcory'
/usr/bin/mkdir /var/vmess

echo 'updating apt repository'
/usr/bin/apt-get update

echo 'installing curl'
/usr/bin/apt-get install curl -y

echo 'installing docker'
#/usr/bin/curl https://get.docker.com/ | sh

echo 'installing docker-compose'
/usr/bin/apt-get install docker-compose -y

echo 'opening port 80'
/usr/bin/ufw allow 80

__ip=`hostname -I | awk '{print $1}'`
__uuid=`/usr/bin/uuidgen`

__config="""
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "allocate": {
        "strategy": "always"
      },
      "settings": {
        "clients": [
          {
            "id": "$__uuid",
            "level": 1,
            "alterId": 0,
            "email": "client@example.com"
          }
        ],
        "disableInsecureEncryption": true
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "connectionReuse": true,
          "path": "/graphql"
        },
        "security": "none",
        "tcpSettings": {
          "header": {
            "type": "http",
            "response": {
              "version": "1.1",
              "status": "200",
              "reason": "OK",
              "headers": {
                "Content-Type": [
                  "application/octet-stream",
                  "application/x-msdownload",
                  "text/html",
                  "application/x-shockwave-flash"
                ],
                "Transfer-Encoding": ["chunked"],
                "Connection": ["keep-alive"],
                "Pragma": "no-cache"
              }
            }
          }
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}"""

echo $__config > /var/vmess/config.json

echo 'running vmess service'
/usr/bin/docker-compose up -d /var/vmess/


__cfg="""
{"add":"$__ip","aid":"0","alpn":"","host":"","id":"$__uuid","net":"ws","path":"/graphql","port":"80","ps":"musa zade","scy":"chacha20-poly1305","sni":"","tls":"","type":"","v":"2"}
"""

echo 'your config is ready'

__base64cfg=`echo $__cfg | base64`
echo 'vmess://$__base64cfg'

