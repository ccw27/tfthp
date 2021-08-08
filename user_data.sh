#! /bin/bash
#set -x


# --------------------------------------------------------------------------
# iptables
# --------------------------------------------------------------------------
# Flush INPUT/OUTPUT/FORWARD chains
iptables -F
iptables -X

# Drop invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Pass everything on loopback
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Accept incoming packets for established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Accept incoming ICMP
# iptables -A INPUT -p icmp -j ACCEPT

# Accept incoming SSH,http,https on eth0 interface
iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT

# Prevent DoS attack
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# blocking null packets.
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Fragmented Packet:
iptables -A INPUT -f -j DROP

# Force SYN Packet Check:
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# XMAS Packet:
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Log dropped packets
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP

# Accept outgoing connections
iptables -P OUTPUT ACCEPT

# Drop everything else on INPUT/FORWARD
iptables -P INPUT   DROP
iptables -P FORWARD DROP


# --------------------------------------------------------------------------
# install docker
# --------------------------------------------------------------------------
apt-get update

# set up the Docker repository
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# set up the stable repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y

# Start docker
while [ $(systemctl is-active docker) == 'inactive' ]
do
    sleep 5
    systemctl start docker
done


# --------------------------------------------------------------------------
# Deploy/Start an Nginx container on that VM instance
# --------------------------------------------------------------------------
# install docker-compose
apt-get install -y docker-compose

# create docker-compose.yaml file
cat > /root/docker-compose.yaml <<EOF
version: '3.6'
services:
  nginx:
    image: nginx
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
    healthcheck:
      test: curl --fail -s http://localhost:80/ || exit 1
EOF

# Start Nginx container
docker-compose -f /root/docker-compose.yaml up -d


# --------------------------------------------------------------------------
# Log the resource usage of the containers every 10 seconds to /var/log/syslog
# --------------------------------------------------------------------------
echo "*/10 * * * * root logger \$(docker ps -q | xargs  docker stats --no-stream |grep -v CONTAINER)" > /etc/cron.d/container-usage
