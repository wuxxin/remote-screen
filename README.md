# html5 based shared remote keyboard/mouse/screen service

TLDR: Use a webbrowser to access a webbrowser.

Shared remote access is implemented using different backend technologies (vnx, xpra, spice).
Inside the container you have a chromium-browser, firefox, atom and evince installed.

In addition to remote access,
you can relay your local computer screen to the webservice, using the vnc-relay.sh script on the serverside and a x11vnc and ssh on the client side. In comparison to skype the screen quality should be very good also at high-resolutions.


## Quickstart

### Setup
1. add ssh public keys of users who should start/control a remote session to authorized_keys
1. deploy container
  1. link port 22 of container to an outside port for ssh connection
  1. link port 5000 of container to a https web frontend with websocket support (nginx works)
    (eg. using dokku)

#### Environment
* REMOTE_VIEWONLY_PASSWORD= "yourviewonlypassword"
  * if "" or "unset" a random password will be created at runtime
* REMOTE_READWRITE_PASSWORD= "yourreadwritepassword"
  * if "" or "unset" a random password will be created at runtime
* REMOTE_AUTOMATIC_VIEW= true
  * if true, write the viewonly password to index.html for autoconnect at runtime
  * if false, the automatic viewonly connect will ask for the password

### Usage

#### vnc: read/write and view access to a browser running in the container

1. `ssh user@yourserver.yourdomain -p yoursshport "vnc-client.sh"`
  * the terminal output shows you the view and the read/write password
1. point your webbrowser to `https://yourserver.yourdomain/` to connect readonly or
  `https://yourserver.yourdomain/vnc_auto.html` and input password


#### Experimental

##### vnc: tunnel a x11vnc from your local computer to a relay on the server side

1. start your browser, get windowid (eg. 0x4000001)
1. `x11vnc -display :0 -ncache 10 -forever -shared -viewonly -sid windowid`
1. `ssh -R localhost:5900:localhost:5900 user@yourserver.yourdomain -p yoursshport   "vnc-relay.sh"`
1. point your webbrowser to `https://yourserver.yourdomain/` to connect readonly or
`https://yourserver.yourdomain/vnc_auto.html` and input password

##### spice: read/write access to a browser running in the container
  * Describe me ( look inside spice-client.sh )

##### xpra: read/write and view access to a browser running in the container
  1. `ssh user@yourserver.yourdomain -p yoursshport "~/xpra-client.sh chromium-browser"`
  2. point your webbrowser to `https://yourserver.yourdomain/` to connect readonly or
    `https://yourserver.yourdomain/connect.html` and select "readwrite" for keyboard/mouse access

## Todo

* generalize XStartup so every local client can do the same setup
* WIP: screen-cast.sh

### remarks xpra-html5
 * Contra: sharing and read/write viewonly is very experimental
 * Pro: Very crispy screen quality, including compositing, low bandwidth, audio

#### fixme
 * read/write also should not trigger resize away from 1024x768 (easy)
 * wrong keyboard, should be right or hardcoded to de
 * timeouts and reconnect need, why are they, can we fix them, are they only as the presenter or also as viewer ?

### remarks vnc

* Contra: legacy protocol, no audio, no other side channel, limited capabilities
* pro: mature, works, low bandwidth, ok screen quality, html client is not bitrotten or experimental like the others

### remarks xspice

* Pro: versatile (QEMU Server Support, X11 Server Support), Audio, remote USB sharing and other fancy stuff for relaying, very crispy screen quality, smooth screen updates
* Contra: client bitrotten, smooth but slow screen updates, high-bandwith
