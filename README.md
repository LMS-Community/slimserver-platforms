Some amendments to enable the use of a systemd unit file for the RPM distribution.

- The unit file itself squeezeboxserver.service
- A new version of the /etc/sysconfig/squeezeboxserver (squeezeboxserver.config)
- A new file README.systemd with some explanations about the migration from SYSV to systemd
- An amended squeezeboxserver.spec
- An amended buildme.pl (just added the two new files to be copied to the RPM source directory).

In addition to the support of systemd, I also fixed the issues with the missing symbolic link to

- /usr/lib/perl5/site_perl/Slim for SUSE distributions
- /usr/lib64/perl5/vendor_perl/Slim for RedHat based x86_64 distributions


