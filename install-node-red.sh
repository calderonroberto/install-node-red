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
# I am assuming you have raspbian >3.18.5, 
# when you issue the command "uname -r" you get 
# 'Linux raspberrypi 3.18.5+ #744...' 
# This script will work with an installation via NOOBS_v1_3_12
#
## LIMITATIONS
# + This script will only work for Raspberry Pi v1 (as v2 has a different CPU archicture)
# + This is intended as an initial setup. There are important security flaws:
# + The /etc/init.d/node-red file is using the root user making it insecure
#    for production. 
# + Node-RED runs with a garbage collection size of 128, can be optimized as 64
# + This script was tested with a clean install of raspbian NOOBS 

INITFILE=https://raw.githubusercontent.com/calderonroberto/install-node-red/master/node-red
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
    $SUDO apt-get -y install python-dev
    $SUDO apt-get -y install python-rpi.gpio
  } || { #catch block
    echo -e "${RED}ERROR: There was a problem installing GPIO dependencies${NC}" 
    exit 
  }
else
  echo -e "${GREEN}GPIO dependencies already installed${NC}"
fi

## Install nodejs optimized for the raspberry pi architecture.
##
if [ -a node_0.10.36_armhf.deb ]; then
  echo -e "${GREEN}NodeJS is already installed${NC}"
else 
  echo -e "${GREEN}Downloading and installing nodejs for raspberry pi${NC}"
  {
    #Install node
    $SUDO wget http://node-arm.herokuapp.com/node_0.10.36_armhf.deb
    $SUDO dpkg -i node_0.10.36_armhf.deb    
  } || {
    echo -e "${RED}ERROR: There was a problem installing nodejs${NC}"
    exit
  }
fi 

## Download and install NodeRED via github, this will compile and install nodered
##
DIR='node-red'
if [ -d "$DIR" ]; then
  echo -e "${GREEN}It seems like node-red is already installed. If you want a new installation delete the directory '$DIR'${NC}" 
else
  echo -e "${GREEN}Downloading, compiling and installing node-red${NC}"
  {
    $SUDO git clone https://github.com/node-red/node-red.git
    cd node-red
    $SUDO npm install --production
  } || {
    echo -e "${RED}ERROR: there was a problem installing node-red${NC}"
    exit
  }
fi

## Finally, set up an init.d script to configure nodeRED to start at boot
##
if [ -a /etc/init.d/node-red ]; then
  echo -e "${GREEN}init.d script already configured${NC}"
else 
  echo -e "${GREEN}Downloading init.d script. Configuring to start at boot${NC}"
  {
    $SUDO wget --output-document run-node-red $INITFILE
    $SUDO chmod 755 run-node-red
    $SUDO chown root:root run-node-red
    $SUDO mv run-node-red /etc/init.d/node-red
    $SUDO update-rc.d node-red defaults
    echo 'Starting service'
    $SUDO service node-red start
  } || {
    echo -e "${RED}ERROR: there was a problem downloading and configuring the init.d script${NC}"
    exit
  }
fi

echo -e "${GREEN}Yay! You have node running.${NC}"
echo -e "${GREEN}Visit http://<your PI address>:1880/ to begin noding in awe.${NC}"
-e "${GREEN}You can use the following nodes to test your configuration.${NC}"
echo ' '
echo '[{"id":"2462d9f5.db9d26","type":"function","name":"Toggle 0/1 on input","func":"\ncontext.state = context.state || 0;\n\n(context.state == 0) ? context.state = 1 : context.state = 0;\nmsg.payload = context.state;\n\nreturn msg;","outputs":1,"x":362,"y":76,"z":"2fd1a8b8.d02e58","wires":[["f7fad3c0.08053"]]},{"id":"47794a9.fb886b4","type":"debug","name":"","active":true,"x":341,"y":146.00002098083496,"z":"2fd1a8b8.d02e58","wires":[]},{"id":"bc3c8444.43c378","type":"inject","name":"tick every 3 secs","topic":"","payload":"","payloadType":"date","repeat":"4","crontab":"","once":false,"x":160,"y":76.00002098083496,"z":"2fd1a8b8.d02e58","wires":[["2462d9f5.db9d26"]]},{"id":"f7fad3c0.08053","type":"rpi-gpio out","name":"","pin":"12","set":false,"out":"out","x":533.8333740234375,"y":75.83333396911621,"z":"2fd1a8b8.d02e58","wires":[]},{"id":"8035245c.7fcad8","type":"rpi-gpio in","name":"","pin":"16","intype":"tri","read":true,"x":182,"y":145.8333339691162,"z":"2fd1a8b8.d02e58","wires":[["47794a9.fb886b4"]]}]'



