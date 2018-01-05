---
title: "Updating DynDNS Service with your Raspberry"
date: 2018-05-01T23:38:52+01:00
weight: 1
---

It's super easy to update your DynDNS Serviceprovider with your Router as long as it's only one Rule. But for this Domain I had the problem that Traefik is acting as my reverse Proxy and I don't want to configure every subdomain statically. Therefore I choosed to use a wildcard "*" and my standard "@" Host. Which means 2 Rules.

![wired](/images/img/screens/dyndns.jpg?classes=border&width=500px)

While it's still easy to update one of them, it needs a little script to update both.
This Python script isn't really good and has absolutely no errorhandling or any kind of sweetness but it works:

```python
#!/usr/bin/env python
"""Namecheap updater."""

from json import load
import urllib2
import time
import os
import datetime

# default "ip", will be changed
ip = 0
# ip service provider :)
my_ip = load(urllib2.urlopen('https://api.ipify.org/?format=json'))['ip']

while True:
    if ip == my_ip:
        time.sleep(300)	# sleep for 5 minutes before checking again
        ip = load(urllib2.urlopen('https://api.ipify.org/?format=json'))['ip']
    else:
        url_at = "http://dynamicdns.park-your-domain.com/update?host=%s&domain=%s&password=%s&ip=%s" % (os.environ["host"], os.environ["domain"], os.environ["pass"], my_ip)
        url_wc = "http://dynamicdns.park-your-domain.com/update?host=%s&domain=%s&password=%s&ip=%s" % (os.environ["host2"], os.environ["domain"], os.environ["pass"], my_ip)
        urllib2.urlopen(url_at).read()	# update namecheap no.1
        urllib2.urlopen(url_wc).read()  # update namecheap no.2
        ip = load(urllib2.urlopen('https://api.ipify.org/?format=json'))['ip']
        my_ip = load(urllib2.urlopen('https://api.ipify.org/?format=json'))['ip']
        ti = time.time()
        ts = datetime.datetime.fromtimestamp(ti).strftime('%d-%m-%Y %H:%M:%S')
        print "%s IP changed to %s" % (ts, my_ip)	# timestamp + infolog
```

While this was working on first attempt I placed it in a container and it's now running for a few days, therefore I thought it's time to publish it on **[github](https://github.com/zepptron/rpi-ncup)**

Just pass some environment variables and use it. Feel free to configure it to your needs. 

```
version: "3"
services:
  ncup:
    image: zepp/rpi-ncup:latest
    environment:
      pass: "_YOUR_TOKEN_"
      domain: "cest.io"
      host: "*"
      host2: "@"
    deploy:
      restart_policy:
        condition: on-failure
```
