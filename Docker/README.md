# logitechmediaserver

The [LMS Community](https://github.com/LMS-Community)'s Docker image for [Logitech Media Server](https://github.com/Logitech/slimserver/) ([Dockerfile](https://github.com/Logitech/slimserver-platforms/tree/public/8.2/Docker)).

## Tags
* `latest`: the latest release version, currently v8.3.0
* `stable`: the [bug fix branch](https://github.com/Logitech/slimserver/tree/public/8.1) based on the latest release, currently v8.3.1
* `dev`: the [development version](https://github.com/Logitech/slimserver/), with new features, and potentially less stability, currently v8.4.0

## Installation

Run:

```
docker run -it \
      -v "<somewhere>":"/config":rw \
      -v "<somewhere>":"/music":ro \
      -v "<somewhere>":"/playlist":rw \
      -v "/etc/localtime":"/etc/localtime":ro \
      -v "/etc/timezone":"/etc/timezone":ro \
      -p 9000:9000/tcp \
      -p 9090:9090/tcp \
      -p 3483:3483/tcp \
      -p 3483:3483/udp \
      lmscommunity/logitechmediaserver
```

Please note that the http port always has to be a 1:1 mapping. You can't just map it like `-p 9002:9000`, as Logitech Media Server is telling players on which port to connect. Therefore if you have to use a different http port for LMS (other than 9000) you'll have to set the `HTTP_PORT` environment variable, too:

```
docker run -it \
      -v "<somewhere>":"/config":rw \
      -v "<somewhere>":"/music":ro \
      -v "<somewhere>":"/playlist":rw \
      -v "/etc/localtime":"/etc/localtime":ro \
      -v "/etc/timezone":"/etc/timezone":ro \
      -p 9002:9002/tcp \
      -p 9090:9090/tcp \
      -p 3483:3483/tcp \
      -p 3483:3483/udp \
      -e HTTP_PORT=9002 \
      lmscommunity/logitechmediaserver
```

Docker compose:
```
version: '3'
services:
  lms:
    container_name: lms
    image: lmscommunity/logitechmediaserver
    volumes:
      - /<somewhere>:/config:rw
      - /<somewhere>:/music:ro
      - /<somewhere>:/playlist:rw
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    ports:
      - 9000:9000/tcp
      - 9090:9090/tcp
      - 3483:3483/tcp
      - 3483:3483/udp
    restart: always
```

Alternatively you can specify the user and group id to use:
For run add:
```
  -e PUID=1000 \
  -e PGID=1000
```
For compose add:
```
environment:
  - PUID=1000
  - PGID=1000
```

## Advanced configuration notes

### Docker on Synology
* use `/etc/TZ` instead of `/etc/timezone`
* you'll likely have to use another port than 9000. Synology traditionally used port 9002 to run Logitech Media Server on. See above note about mapping ports to make sure this is working as expected!

### How to manually install plugins
If you're a developer you might want to install plugins manually, before they are available through LMS' built-in plugin manager. In order to do so, put them inside `[config folder]/Cache/Plugins`, then restart LMS. They should be available in thereafter.

### Running a script before the launch of Logitech Media Server (v8.2.0+)
You can put a script called `custom-init.sh` in the configuration folder. If that script exists, it will be executed before Logitech Media Server is launched. This would allow you to add additional software packages to the container. Eg. the following two lines put into `custom-init.sh` will install `ffmpeg` for use with some plugins:
```
apt-get update -qq
apt-get install --no-install-recommends -qy ffmpeg
```
