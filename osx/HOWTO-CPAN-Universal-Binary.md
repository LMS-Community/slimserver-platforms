# How to build universal binary XS CPAN modules

## Building custom Perl

In order to build a portable, system independent Perl installation, I followed these steps:

* install Perlbrew as per instructions on https://perlbrew.pl
* on an Intel based `x86_64` system build a relocatable Perl, with a macOS base target of 10.14:

```shell
MACOSX_DEPLOYMENT_TARGET=10.12 perlbrew install -D usethreads -D userelocatableinc -Dman1dir=none -Dman3dir=none -j4 perl-5.34.0
```

* for the Apple Silicon base system I build for macOS 11.x+:

```shell
MACOSX_DEPLOYMENT_TARGET=11.0 perlbrew install -D usethreads -D userelocatableinc -Dman1dir=none -Dman3dir=none -j4 perl-5.34.0
```

* copy both resulting architecture folders some place into `x86_64` and `arm64` sub folders
* copy one of them to a new folder `fat`
* use the `fatten.sh` script to combine the the two into one universal binary build
* remove everything from `bin` except `perl`

## Build Dependencies

* get code from https://github.com/Logitech/slimserver-vendor/tree/public/x.y/CPAN
* run `buildme.sh`:
```script
./buildme.sh -p ~/path/to/new/perl5.34.0
```
* build `IO::Socket::SSL` and dependencies (it's not apart of the default set of modules built above)
```script
./buildme.sh -p ~/path/to/new/perl5.34.0 IO::Socket::SSL
```
* combine the binaries again as per the previous section

## Old Instructions
*Theoretically you should be able to cross compile on one system. Alas, I didn't succeed building all the binaries following the old instructions. Here they are anyway.*

1. Extract module
2. Create a new file: hints/darwin.pl:

```shell
#!/usr/bin/perl

$arch = "-arch x86_64 -arch arm64";
print "Adding $archn";

$self->{CCFLAGS} = "$arch $Config{ccflags}";
$self->{LDFLAGS} = "$arch $Config{ldflags}";
$self->{LDDLFLAGS} = "$arch $Config{lddlflags}";
```

3. perl Makefile.PL; make; make test
4. The module's bundle file is now a universal binary.
