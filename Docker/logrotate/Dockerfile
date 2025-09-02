FROM alpine:3.22

ENV PUID=499 PGID=100

# Add & configure user
# install needed packages
#
# Alpine already has users group using id 100
#
RUN adduser -u $PUID -G users -s /bin/bash -S squeezeboxserver  && \
    apk add --update --no-cache \
      bash \
      logrotate  \
      supercronic \
      tzdata && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

USER squeezeboxserver
WORKDIR /home/squeezeboxserver

ENTRYPOINT ["/usr/bin/supercronic", "-overlapping", "/conf/crontab"]
