This script provides routine commands to install and configure a default installation of node red in your Raspberry Pi.

** This script is based on instructions found at http://nodered.org/docs/hardware/raspberrypi.html **

## CHANGELOG
+ 2015-02-18- First Version.
 
## STEP-BY-STEP-INSTRUCTIONS

In a console in your Raspberry Pi issue: 

```
cd ~
wget https://raw.githubusercontent.com/calderonroberto/install-node-red/master/install-node-red.sh
bash install-node-red.sh
```

you can also use a shortened version if you're SSHing into your pi:

```
cd ~
wget http://bit.do/install-node-red
bash install-node-red
```

A bit of patience while it compiles and installs node-red and you're done.

## ASSUMPTIONS

I am assuming you have raspbian >3.18.5, that is when you issue the command "uname -r" you get 

```
$ uname -r
Linux raspberrypi 3.18.5+ ... 
```

This script will work with a raspbian installation via NOOBS_v1_3_12+ (http://www.raspberrypi.org/downloads/)

## LIMITATIONS

 + This script will only work for Raspberry Pi v1 (as v2 has a different CPU archicture)
 + This is intended as an initial setup. There are important security flaws, for example the /etc/init.d/node-red file is using the root user making it insecure for production. 
 + In the current init script Node-RED runs with a garbage collection size of 128, can be optimized as 64
 + This script was tested with a clean install of raspbian NOOBS 


