#!/bin/bash
#
# This script is based on instructions posted here:
# http://nodered.org/docs/hardware/raspberrypi.html
#
## INFO:
# This script provides routine commands to install and configure
# a default installation of node red in your Raspberry Pi.
#
## ASSUMPTIONS
# I am assuming you have raspbian >=3.18.11-v7,
# when you issue the command "uname -r" you get
# '3.18.11-v7' or greater
# This script will work with an installation via NOOBS => 1.4.1
#
## LIMITATIONS
# + This script will only work for Raspberry Pi v2
# + This is intended as an initial setup. There are important security flaws:
# + The /etc/init.d/node-red file is using the root user making it insecure
#    for production.
# + Node-RED runs with a garbage collection size of 128, can be optimized as 64
# + This script was tested with a clean install of raspbian NOOBS

SUDO=''

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'

if (( $EUID != 0 )); then
    SUDO='sudo'
fi

cd ~

## You need to install GPIO dependencies (python-dev and python-rpi.gipo)
##
if [ ! dpkg-query -l python-rpi.gpio < /dev/null]; then
  {
    echo -e "${GREEN}Installing GPIO Dependencies.${NC}"
    $SUDO apt-get install -y build-essential python-dev python-rpi.gpio
  } || { #catch block

    echo -e "${RED}ERROR: There was a problem installing GPIO dependencies${NC}"
    exit
  }
else
  echo -e "${GREEN}GPIO dependencies already installed${NC}"
fi


## Install nodejs optimized for the raspberry pi architecture (ARM)
##
if [ ! dpkg-query -l nodejs < /dev/null ]; then
  echo -e "${GREEN}NodeJS is already installed${NC}"
else
  echo -e "${GREEN}Installing nodejs for raspberry pi${NC}"
  {
    #Install node
    $SUDO curl -sL https://deb.nodesource.com/setup_0.10 | $SUDO bash
    $SUDO apt-get install -y nodejs
  } || {
    echo -e "${RED}ERROR: There was a problem installing nodejs${NC}"
    exit
  }
fi

## Download and install NodeRED via NPM
##
#DIR='/usr/lib/node_modules/node-red'

NODEREDBIN="$(which node-red)"
if [ -a "$NODEREDBIN" ]; then
  echo -e "${GREEN}It seems like node-red is already installed. If you want a new installation remove node-red with `npm uninstall -g node-red` "
else
  echo -e "${GREEN}Downloading, compiling and installing node-red${NC}"
  {
    $SUDO npm install -g --unsafe-perm node-red
    $SUDO npm cache clean
  } || {
    echo -e "${RED}ERROR: there was a problem installing node-red${NC}"
    exit
  }
fi

## Install Interesting Nodes.
echo -e "${GREEN}Downloading, compiling and installing complimentary nodes${NC}"
{
  $SUDO npm install -g \
  node-red-contrib-wotkit \
  node-red-contrib-web-nodes \
  node-red-node-web-nodes \
  node-red-node-pushbullet \
  node-red-node-wordpos \
  node-red-node-xmpp \
  node-red-node-badwords \
  node-red-node-suncalc \
  node-red-node-smooth \
  node-red-node-ping \
  node-red-contrib-moment \
  node-red-node-fitbit \
  node-red-contrib-slack
} || {
  echo -e "${RED}ERROR: there was a problem installing node-red${NC}"
  exit
}


## Finally, set up node red to run on boot
##

NODEREDBIN="$(which node-red)"
PM2BIN="$(which pm2)"
echo -e "${GREEN}Configuring to start nodered at boot via $NODEREDBIN ${NC}"
{
  echo 'Installing pm2'
  $SUDO npm install -g pm2
  echo 'Deleting previous configurations and starting service'
  $SUDO pm2 delete node-red
  $SUDO pm2 start $NODEREDBIN --node-args="--max-old-space-size=128" -- -v
  echo 'Configuring for startup'
  $SUDO pm2 save
  $SUDO pm2 startup
} || {
  echo -e "${RED}ERROR: there was a problem configuring start on boot${NC}"
  exit
}

HOSTNAMEIP="$(hosname -I)"
echo -e "${GREEN}Yay! You have node-red up and running.${NC}"
echo -e "${GREEN}Visit http://$HOSTNAMEIP:1880/ to begin noding in awe.${NC}"
echo -e "${GREEN}You can use the following nodes to test your configuration.${NC}"
echo ' '
echo '[{"id":"2462d9f5.db9d26","type":"function","name":"Toggle 0/1 on input","func":"\ncontext.state = context.state || 0;\n\n(context.state == 0) ? context.state = 1 : context.state = 0;\nmsg.payload = context.state;\n\nreturn msg;","outputs":1,"x":362,"y":76,"z":"2fd1a8b8.d02e58","wires":[["f7fad3c0.08053"]]},{"id":"47794a9.fb886b4","type":"debug","name":"","active":true,"x":341,"y":146.00002098083496,"z":"2fd1a8b8.d02e58","wires":[]},{"id":"bc3c8444.43c378","type":"inject","name":"tick every 3 secs","topic":"","payload":"","payloadType":"date","repeat":"3","crontab":"","once":false,"x":160,"y":76.00002098083496,"z":"2fd1a8b8.d02e58","wires":[["2462d9f5.db9d26"]]},{"id":"f7fad3c0.08053","type":"rpi-gpio out","name":"","pin":"12","set":false,"out":"out","x":533.8333740234375,"y":75.83333396911621,"z":"2fd1a8b8.d02e58","wires":[]},{"id":"8035245c.7fcad8","type":"rpi-gpio in","name":"","pin":"16","intype":"tri","read":true,"x":182,"y":145.8333339691162,"z":"2fd1a8b8.d02e58","wires":[["47794a9.fb886b4"]]}]'
