#!/bin/bash

# This script is based on instructions posted here:
# http://nodered.org/docs/hardware/raspberrypi.html

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
  echo -e "${GREEN}Downloading and installing nodejs for raspberry pi${NC}"
  {
    #Install node
    $SUDO wget http://node-arm.herokuapp.com/node_0.10.36_armhf.deb
    $SUDO dpkg -i node_0.10.36_armhf.deb    
  } || {
    echo -e "${RED}ERROR: There was a problem installing nodejs${NC}"
    exit
  }
else 
  echo -e "${GREEN}NodeJS is already installed${NC}"
fi 

## Download and install NodeRED via github, this will compile and install nodered
##
DIR='node-red'
if [ -d "$DIR" ]; then
  echo -e "${GREEN}It seems like node-red is already installed. If you want a new installation delete ${NC}" + $DIR
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
if [ ! -a /etc/init.d/node-red ]; then

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
else 
  echo -e "${GREEN}Downloading init.d script already configured${NC}"
fi


echo -e "${GREEN}Yay! You have node running.${NC}"
echo -e "${GREEN}Visit http://<your PI address>:1880/ to begin noding in awe.${NC}"
-e "${GREEN}You can use the following nodes to test your configuration.${NC}"
echo ' '
echo '[{"id":"4b38c007.b4c74","type":"function","name":"Toggle 0/1 on input","func":"\ncontext.state = context.state || 0;\n\n(context.state == 0) ? context.state = 1 : context.state = 0;\nmsg.payload = context.state;\n\nreturn msg;","outputs":1,"x":356,"y":89.16668701171875,"z":"a546cb60.5ab938","wires":[["800c9a62.7ff368"]]},{"id":"ae9e4ce.f5161b","type":"debug","name":"","active":true,"x":335,"y":159.1667079925537,"z":"a546cb60.5ab938","wires":[]},{"id":"d64224d0.29bdd8","type":"inject","name":"tick every 1 sec","topic":"","payload":"","payloadType":"date","repeat":"4","crontab":"","once":false,"x":154,"y":89.16670799255371,"z":"a546cb60.5ab938","wires":[["4b38c007.b4c74"]]},{"id":"800c9a62.7ff368","type":"rpi-gpio out","name":"","pin":"7","set":false,"out":"out","x":527.8333740234375,"y":89.00002098083496,"z":"a546cb60.5ab938","wires":[]},{"id":"4ffdc9dc.b00238","type":"rpi-gpio in","name":"","pin":"11","intype":"tri","read":true,"x":176,"y":159.00002098083496,"z":"a546cb60.5ab938","wires":[["ae9e4ce.f5161b"]]}]'



