#!/bin/bash

# Configure environment
export DEBIAN_FRONTEND="noninteractive"

# Configure user squeezeboxserver
useradd squeezeboxserver
usermod -u 99 squeezeboxserver
usermod -g 100 squeezeboxserver
usermod -d /home squeezeboxserver
chown -R squeezeboxserver:users /home

# Allow acces to /dev/snd
usermod -a -G audio squeezeboxserver
