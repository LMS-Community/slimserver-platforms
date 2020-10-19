#Base image
FROM debian:9-slim

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV HOME="/root"

# Install packages
RUN apt-get update -qq  && \
	apt-get install --no-install-recommends -qy wget curl perl tzdata libwww-perl libio-socket-ssl-perl libnet-ssleay-perl libdata-dump-perl libcrypt-ssleay-perl && \
	apt-get clean -qy && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add & install LMS sript
COPY install.sh /tmp/
RUN chmod +x /tmp/install.sh
RUN /tmp/install.sh

COPY server/ /opt/lms/
COPY Custom-Slim-Utils-OS.pm /opt/lms/Slim/Utils/OS/Custom.pm

# Add startup script
COPY start-container.sh /usr/bin/start-container
RUN chmod +x /usr/bin/start-container

# Volume and port setup
RUN mkdir -p /config /music /playlist

VOLUME /config /music /playlist

EXPOSE 3483 3483/udp 9000 9090

#Startup setup
WORKDIR /config

ENTRYPOINT ["start-container"]