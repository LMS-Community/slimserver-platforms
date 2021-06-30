#Base image
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV PUID=99 PGID=100
ENV HTTP_PORT=9000

# Install packages
RUN apt-get update -qq  && \
	apt-get install --no-install-recommends -qy wget curl perl tzdata libwww-perl libfont-freetype-perl liblinux-inotify2-perl libdata-dump-perl libio-socket-ssl-perl libnet-ssleay-perl libcrypt-ssleay-perl libcrypt-openssl-rsa-perl libgomp1 lame && \
	apt-get clean -qy && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add & configure user
RUN useradd squeezeboxserver && \
	usermod -u $PUID squeezeboxserver && \
	usermod -g $PGID squeezeboxserver && \
	usermod -d /home squeezeboxserver && \
	usermod -a -G audio squeezeboxserver

# Add startup script
COPY start-container.sh /usr/bin/start-container
RUN chmod +x /usr/bin/start-container

# Volume and port setup
RUN mkdir -p /config /music /playlist /lms && \
	chown -R squeezeboxserver:nogroup /config /playlist

COPY . /lms
COPY Slim-Utils-OS-Custom.pm /lms/Slim/Utils/OS/Custom.pm

VOLUME /config /music /playlist

EXPOSE 3483 3483/udp ${HTTP_PORT} 9090

#Startup setup
WORKDIR /config

ENTRYPOINT ["start-container"]