#Base image
FROM debian:9-slim

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV PUID=99 PGID=100

# Install packages
RUN apt-get update -qq  && \
	apt-get install --no-install-recommends -qy sudo wget curl perl tzdata libwww-perl libio-socket-ssl-perl libnet-ssleay-perl libdata-dump-perl libcrypt-ssleay-perl && \
	apt-get clean -qy && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /config /music /playlist

# Add & configure user
RUN useradd squeezeboxserver && \
	usermod -u $PUID squeezeboxserver && \
	usermod -g $PGID squeezeboxserver && \
	usermod -d /home squeezeboxserver && \
	chown -R squeezeboxserver:users /config /playlist && \
	usermod -a -G audio squeezeboxserver

# Add startup script
COPY start-container.sh /usr/bin/start-container
RUN chmod +x /usr/bin/start-container

# Install LMS
COPY . /lms
COPY Slim-Utils-OS-Custom.pm /lms/Slim/Utils/OS/Custom.pm

# Volume and port setup
VOLUME /config /music /playlist

EXPOSE 3483 3483/udp 9000 9090

#Startup setup
WORKDIR /config

ENTRYPOINT ["start-container"]
