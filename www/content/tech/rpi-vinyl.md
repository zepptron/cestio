---
title: "Vinyl and Raspberry Pi"
date: 2017-11-24T16:38:52+01:00
weight: 2
---

Since vinyl is getting bigger and bigger these days and lots of people have some old players somewhere in their cellar it might be usefull to read the following lines in order to upgrade it to something thats fits for the 21st century. Most of the time the "new generation players" don't have the quality you'd expect when you compare them to some old models. You might also want to place your vinylplayer somewhere in the corner of your room and not next to your TV just to be able to plug it into your amplifier via the short cable. 

What I'm going to show you is pretty straigt forward:

- the necessary additional hardware (cheap or expensive -> your choice!)
- integrate vinylplayer to your wlan via Raspberry Pi (place it anywhere)
- expose your vinyl to your (local) network, join stream with different devices

Check out my gitrepo for further info: [zepptron/vinyl0r](https://github.com/zepptron/vinyl0r)

Enough introduction, lets start with the hardware.

### Getting stuff together

You'll need a Raspberry Pi (I'm using a Zero W) and an external soundcard like the Behringer UCA222. 
This setup should be pretty comfortable because many people already have that. 
And also, if not already integrated, you'll need a preamplifier, here you can choose how much you want to spend.
You could also choose a preamp with USB out if you find something, then you won't need the external soundcard. Just make sure that you can run it with your Raspberry. Since this is some standard hardware you can choose whatever you like. Just make sure you can connect everything afterwards. 

Unfortunately the Raspberry Pi has no Audio Input right now and I believe this feature won't show up in the next couple of years. This is why you need an external device. If you find a device like the raspberry that has an audio input for cinch and linux on top, please let me know :)

- [Behringer UCA222](https://www.amazon.com/Behringer-U-Control-Ultra-Low-Interface-Software/dp/B0023BYDHK/ref=sr_1_1?s=electronics&ie=UTF8&qid=1513687767&sr=8-1&keywords=Behringer+UCA222)
- [PreAmp (exp)](https://www.amazon.com/Musical-Fidelity-V90-LPS-Phono-Preamp/dp/B010FZ0JEQ/ref=sr_1_1?s=electronics&ie=UTF8&qid=1513687798&sr=1-1&keywords=musical+fidelity+v90)
- [PreAmp (cheap)](https://www.amazon.com/Pyle-Phono-Turntable-Preamp-Preamplifier/dp/B00025742A/ref=sr_1_3?s=electronics&ie=UTF8&qid=1513687825&sr=1-3&keywords=phono+preamp)
- [Raspberry Pi Zero W (or other)](https://www.amazon.com/CanaKit-Raspberry-Wireless-Official-Supply/dp/B071L2ZQZX/ref=sr_1_3?s=electronics&ie=UTF8&qid=1513687189&sr=1-3&keywords=raspberry+pi+zero+w)

I've had some bad experiences with the soundquality of low budged preamps but others tell me that I'm stupid and there is no difference. You better check that on your own. Maybe I can hear the money I've spend...

### Connect all the things!!

So what we'll build is basically this:

{{<mermaid align="left">}}
graph LR;
    A[Vinylplayer]-->|Cinch| B[PreAmp]
    B --> |Cinch| C[USB Audio IN/OUT]
    C --> |USB| D[RaspberryPi]
    D --> |WLAN| E[Any Device]
{{< /mermaid >}}

If your vinylplayer got an old DIN-connector, cut it and replace it with [cinch](https://www.amazon.de/Goobay-Cinchstecker-schwarz-high-quality/dp/B000L0ZO78/ref=sr_1_4?ie=UTF8&qid=1509494006&sr=8-4&keywords=cinch+stecker). Or buy the corresponding converter for 5$.
Now connect your vinyl player to the preamp, the preamp to the audio IN on the usb soundcard and then from the usb audiodevice (Out) to the raspberry. Straight forward, you can't do much wrong here.

![wired](/img/rpi/vinyl0r-wired.jpg)

### Setting up the Raspberry
Install Raspbian on your Raspberry and configure SSH so you can access it. It's also better to use a static IP or a DNS name that doesn't change because you want to access it with via URL later. I won't cover these basics here, please [check the internet](http://lmgtfy.com/?q=setting+up+raspberry+static+ip) for your type of Raspberry. 

### Setting up the software
You'll use darkice to get your audiostuff from your usb-device and icecast will publish it afterwards to your local network.
So basically darkice is doing the invisible work while icecast is publishing everything as a stream.

```bash
sudo apt-get install darkice
```

Grab the content of **darkice.cfg** from my updated [github repo](https://github.com/zepptron/vinyl0r/tree/master/etc) and copy everything into **/etc/darkice.cfg** on your raspberry.
If it's not already present, create it via `touch /etc/darkice.cfg`.

```bash
# this section describes general aspects of the live streaming session
[general]
duration      = 0                # duration of encoding, in seconds. 0 means forever
bufferSecs    = 5                # size of internal slip buffer, in seconds
reconnect     = yes              # reconnect to the server(s) if disconnected

# this section describes the audio input that will be streamed
[input]
device        = hw:1,0           # Alsa soundcard device for the audio input
sampleRate    = 44100            # sample rate in Hz. try 11025, 22050 or 44100
bitsPerSample = 16               # bits per sample. try 16
channel       = 2                # channels. 1 = mono, 2 = stereo

# this section describes a streaming connection to an IceCast2 server
# there may be up to 8 of these sections, named [icecast2-0] ... [icecast2-7]
# these can be mixed with [icecast-x] and [shoutcast-x] sections
[icecast2-0]
bitrateMode   = vbr              # variable bit rate
format        = vorbis           # format of the stream: mp3
quality       = 1.0              # quality of the stream sent to the server
server        = localhost      	 # host name of the server
port          = 8000             # port of the IceCast2 server, usually 8000
password      = fuckoff          # source password to the IceCast2 server
mountPoint    = raspi            # mount point of this stream on the IceCast2 server
name          = vinyl0r          # name of the stream
description   = vinyl on raspi   # description of the stream
url           = http://localhost # URL related to the stream
genre         = soulpunk         # genre of the stream
public        = no               # advertise this stream?
```

Adjust some settings (like the password) if you want. Otherwise it will just work somehow.
Please check the input device for it's name to make sure it'll work.
If you have no idea what your device is called use `arecord -l`.

```bash
**** List of CAPTURE Hardware Devices ****
card 1: CODEC [USB Audio CODEC], device 0: USB Audio [USB Audio]
  Subdevices: 0/1
  Subdevice #0: subdevice #0
```

Yes, This is what you are looking for. It's for this part in the config above:

```bash
[input]
device = hw:1,0 
```

Hardware: Card 1, device 0. Adjust it if you have something different.

### Install and configure Icecast

```bash
sudo apt-get install icecast2 
```

While the installation runs you'll configure it. No hard stuff here. Just keep everything in sync with your settings.

- **Configure Icecast?** -> Yes
- **Icecast Hostname?** -> localhost
- **Icecast Password?** -> Wh0cares?!
- **Icecast Relay Password?** -> Wh0cares?!
- **Icecast Admin Password?** -> Wh0cares?!

### Use it

Take the IP address of the raspberry, add port 8000 to it (or whatever you configured above) and add the mountpoint (see configfile).
It should look like this:

```bash
http://192.168.0.2:8000/raspi.
```

If it's working. Nice. If not, start again or post your questions to my public Slackchannel.

You can add that link to almost any relevant platform like Kodi/XBMC, any Browser or even your main Amplifier could have that feature. Publish the Port to the internet if you like, but take care of the security first! 

### Make it smart with systemd (optional)

If you don't want to do anything manually after a restart of the Raspberry, copy the contents of the darkice servicefile to **/lib/systemd/system**. 

To do so, go root!

```bash
sudo -i
touch /lib/systemd/system/darkice_unit.service
```

double check:
```bash
ls -lah /lib/systemd/system | grep dark
-rw-r--r--  1 root root  193 Oct 31 23:02 darkice_unit.service
```

Copy this into the unitfile you just created: 

```xxx
[Unit]
Description=DarkIce is used to enable Icecast
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/darkice > /dev/null
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

afterwards, let systemd take care of restarts.

```bash
systemctl enable darkice_unit.service
```

This will place a symlink for darkice to **/etc/systemd/system/multi-user.target.wants/** in order to make it persistent. Otherwise it's gone after the next reboot.

now you can checkout everything with systemd tools:

```bash
systemctl status darkice_unit.service
...
systemctl status icecast2.service
...
systemctl restart darkice_unit.service
...
systemctl stop icecast2.service
...
```

Thats the magic. This will save you some time in the future.