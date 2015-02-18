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

INITFILE=https://gist.githubusercontent.com/calderonroberto/251d71ffd7f07d8dadee/raw/9a0f81fdfa1afdf4b22e46f2fe5532e5d10c0f1d/node-red
SUDO=''

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'

if (( $EUID != 0 )); then
    SUDO='sudo'
fi

echo -e "${GREEN}Installing GPIO dependencies${NC}"
{ 
   $SUDO apt-get update
   $SUDO apt-get -y install python-dev python-rpi.gpio
} || { #catch block
    echo -e "${RED}ERROR: There was a problem installing GPIO dependencies${NC}" 
    exit 
}

echo -e "${GREEN}Downloading and installing nodejs for raspberry pi${NC}"
{
   #Install node
   $SUDO wget http://node-arm.herokuapp.com/node_0.10.36_armhf.deb
   $SUDO dpkg -i node_0.10.36_armhf.deb
   echo 'Cleaning up'
   $SUDO rm node_0.10.36_armhf.deb
} || {
   echo -e "${RED}ERROR: There was a problem installing nodejs${NC}"
   exit
}

echo -e "${GREEN}Downloading, compiling and installing node-red${NC}"
{
   DIR='node-red'
   if [ -d "$DIR" ]; then
       printf '%s\n' "Removing Previous Installation ($DIR)"
       rm -rf "$DIR"
   fi

   $SUDO git clone https://github.com/node-red/node-red.git
   cd node-red
   $SUDO npm install --production
} || {
   echo -e "${RED}ERROR: there was a problem installing node-red${NC}"
   exit
}

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

echo -e "${GREEN}Yay! You have node running, here is a node configuration you can use to test:${NC}"
echo 'Visit http://<your PI address>:1880/ to begin noding in awe.'
echo '[{"id":"4b38c007.b4c74","type":"function","name":"Toggle 0/1 on input","func":"\ncontext.state = context.state || 0;\n\n(context.state == 0) ? context.state = 1 : context.state = 0;\nmsg.payload = context.state;\n\nreturn msg;","outputs":1,"x":356,"y":89.16668701171875,"z":"a546cb60.5ab938","wires":[["800c9a62.7ff368"]]},{"id":"ae9e4ce.f5161b","type":"debug","name":"","active":true,"x":335,"y":159.1667079925537,"z":"a546cb60.5ab938","wires":[]},{"id":"d64224d0.29bdd8","type":"inject","name":"tick every 1 sec","topic":"","payload":"","payloadType":"date","repeat":"4","crontab":"","once":false,"x":154,"y":89.16670799255371,"z":"a546cb60.5ab938","wires":[["4b38c007.b4c74"]]},{"id":"800c9a62.7ff368","type":"rpi-gpio out","name":"","pin":"7","set":false,"out":"out","x":527.8333740234375,"y":89.00002098083496,"z":"a546cb60.5ab938","wires":[]},{"id":"4ffdc9dc.b00238","type":"rpi-gpio in","name":"","pin":"11","intype":"tri","read":true,"x":176,"y":159.00002098083496,"z":"a546cb60.5ab938","wires":[["ae9e4ce.f5161b"]]}]'



