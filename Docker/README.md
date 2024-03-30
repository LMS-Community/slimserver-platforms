# logitechmediaserver

The [LMS Community](https://github.com/LMS-Community)'s Docker image for [Lyrion Music Server](https://github.com/LMS-Community/slimserver/) ([Dockerfile](https://github.com/LMS-Community/slimserver-platforms/tree/HEAD/Docker)).

## Tags
* `latest`: the latest release version, currently v8.5.0
* `stable`: the [bug fix branch](https://github.com/LMS-Community/slimserver/tree/public/8.5) based on the latest release, currently v8.5.1
* `dev`: the [development version](https://github.com/LMS-Community/slimserver/), with new features, and potentially less stability, currently v9.0.0

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

Please note that the http port always has to be a 1:1 mapping. You can't just map it like `-p 9002:9000`, as Lyrion Music Server is telling players on which port to connect. Therefore if you have to use a different http port for LMS (other than 9000) you'll have to set the `HTTP_PORT` environment variable, too:

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
    environment:
      - HTTP_PORT=9000
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


### If you can't map to `/etc/localtime` or `/etc/timezone`

Some systems wouldn't allow you to map volumes outside specific folders, eg. Unraid. In many of these cases you can define your timezone using an environment variable:

```
  -e TZ=Europe/Zurich
```

### Docker on Synology
* use `/etc/TZ` instead of `/etc/timezone`
* you'll likely have to use another port than 9000. Synology traditionally used port 9002 to run Lyrion Music Server on. See above note about mapping ports to make sure this is working as expected!
* you should either use `host` mode to automatically expose LMS on your network, or add another variable `EXTRA_ARG` with the value `"--advertiseaddr=192.168.0.100"` (where you'd put your NAS' IP address) - see below for details.

### How to manually install plugins
If you're a developer you might want to install plugins manually, before they are available through LMS' built-in plugin manager. In order to do so, put them inside `[config folder]/Cache/Plugins`, then restart LMS. They should be available in thereafter.

### Passing additional launch arguments
Starting with v8.4 an optional `EXTRA_ARGS` environment variable exists for passing additional arguments to Lyrion Music Server process. For example, disabling the web interface could be achieved with `EXTRA_ARGS="--noweb"`.

### Define the service's IP address
Some plugins like eg. the Sounds & Effects, require the player to know the server's IP address. In the default `bridge` networking mode, the internal IP address would be different from what the player can see. Therefore playback would fail - unless we tell Lyrion Music Server what port to announce. This can be done using the above method to define the `--advertiseaddr` parameter:


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
      -e EXTRA_ARGS="--advertiseaddr=192.168.0.100" \
      lmscommunity/logitechmediaserver
```

### Running a script before the launch of Lyrion Music Server (v8.2.0+)
You can put a script called `custom-init.sh` in the configuration folder. If that script exists, it will be executed before Lyrion Music Server is launched. This would allow you to add additional software packages to the container. Eg. the following two lines put into `custom-init.sh` will install `ffmpeg` for use with some plugins:
```
apt-get update -qq
apt-get install --no-install-recommends -qy ffmpeg
```
