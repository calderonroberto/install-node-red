## Synopsis

This script provides routine commands to install and configure node-red in your **Raspberry Pi 2**. The script is maintained to the latest instructions found at [http://nodered.org/docs/hardware/raspberrypi.html](http://nodered.org/docs/hardware/raspberrypi.html), as a bonus it installs a selection of nodes you will find very useful.

## TL;DR

In your Raspbery Pi issue:

```
curl --no-sessionid -sL http://bit.ly/node-red-pi2 | sudo bash
```

## Step by step instructions

In a console in your Raspberry Pi issue:

```
cd ~
curl --no-sessionid -sL https://raw.githubusercontent.com/SenseTecnic/install-node-red-pi2/master/install-node-red.sh | sudo bash
```

If you are in need of a shorter version you can use:

```
curl --no-sessionid -sL http://bit.ly/node-red-pi2 | sudo bash
```

After you're finished you can find your ip address with:

```
hostname -I
```

Then, visit http:://your-rpi-address:1880/, you can then go to "menu > import > clipboard" and import the following nodes. They are a blinking demo, demonstrating also how to read from a digital input.

```
[{"id":"2462d9f5.db9d26","type":"function","name":"Toggle 0/1 on input","func":"\ncontext.state = context.state || 0;\n\n(context.state == 0) ? context.state = 1 : context.state = 0;\nmsg.payload = context.state;\n\nreturn msg;","outputs":1,"x":362,"y":76,"z":"2fd1a8b8.d02e58","wires":[["f7fad3c0.08053"]]},{"id":"47794a9.fb886b4","type":"debug","name":"","active":true,"x":341,"y":146.00002098083496,"z":"2fd1a8b8.d02e58","wires":[]},{"id":"bc3c8444.43c378","type":"inject","name":"tick every 3 secs","topic":"","payload":"","payloadType":"date","repeat":"3","crontab":"","once":false,"x":160,"y":76.00002098083496,"z":"2fd1a8b8.d02e58","wires":[["2462d9f5.db9d26"]]},{"id":"f7fad3c0.08053","type":"rpi-gpio out","name":"","pin":"12","set":false,"out":"out","x":533.8333740234375,"y":75.83333396911621,"z":"2fd1a8b8.d02e58","wires":[]},{"id":"8035245c.7fcad8","type":"rpi-gpio in","name":"","pin":"16","intype":"tri","read":true,"x":182,"y":145.8333339691162,"z":"2fd1a8b8.d02e58","wires":[["47794a9.fb886b4"]]}]
```
For demo purposes we wire a resistor (330 ohms) to pin pin 12, wire pin 12 to pin 16 (to read when it changes) and connect an LED to the resistor and the 3V output. Like so:

![alt tag](https://raw.github.com/SenseTecnic/install-node-red-raspberrypi2/master/blinkwiring.jpg)

You can learn more about the Raspbery Pi's GPIO pins here: [http://pi.gadgetoid.com/pinout](http://pi.gadgetoid.com/pinout)

## Nodes Installed

Currently this script will install the following nodes:

+ node-red-contrib-wotkit
+ node-red-node-web-nodes
+ node-red-node-web-nodes
+ node-red-node-pushbullet
+ node-red-node-wordpos
+ node-red-node-xmpp
+ node-red-node-badwords
+ node-red-node-suncalc
+ node-red-node-smooth
+ node-red-node-ping
+ node-red-contrib-moment
+ node-red-node-fitbit
+ node-red-contrib-slack

If you want to add more nodes to this script send a pull request or post an issue. I'll be happy to add them.

## Assumptions

I am assuming you have raspbian equal or greater than 3.18.11-v7, that is when you issue the command "uname -r" you get

```
$ uname -r
'3.18.11-v7'
```

This script will work with an installation via NOOBS => 1.4.1 [http://www.raspberrypi.org/downloads/](http://www.raspberrypi.org/downloads/)
