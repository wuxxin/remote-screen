# shared html5 websocket based remote application access

chromium-browser, firefox and evince installed in a docker container,
available for shared remote usage via a local webbrowser.
(an up to date firefox or chrome is needed for usage)

## quickstart

1. add your ssh public keys of users who can start a remote session to authorized_keys
2. deploy container
  1. link port 22 of container to an outside port for ssh connection
  2. link port 5000 of container to a https web frontend with websocket support (nginx works)
      (eg. using dokku)
3. `ssh user@yourserver.yourdomain -p yoursshport -c "~/xpra-client.sh chromium-browser"`
4. point your webbrowser to `https://yourserver.yourdomain/` to connect readonly or
  `https://yourserver.yourdomain/connect.html` and select "readwrite" for keyboard/mouse access

## TODO

* Bug: xpra_client.js: readwrite is not honored 
* WIP: xspice-client.sh
* WIP: screen-cast.sh
