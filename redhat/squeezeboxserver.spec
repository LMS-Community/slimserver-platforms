# The following macros can either be defined here or passed into rpmbuild as macros
# This is required:
# %%define _version 7.7
# One (and only one) of the following is required:
# %%define _with_trunk 1
# %%define _with_branch 1
# %%define _with_release 1
# These are required with _with_trunk or _with_branch
# %%define _src_date 2007-12-07
# %%define _rpm_date 20071207
# The following is required with _with_branch
# %%define _branch 7.7

%define increment 1

# Turn off striping of binaries
%global __strip /bin/true

# don't terminate build due to binaries
%global _binaries_in_noarch_packages_terminate_build 0

%define build_trunk %{?_with_trunk:1}0
%define build_branch %{?_with_branch:1}0
%define build_release %{?_with_release:1}0


%if %{build_trunk}
%define rpm_release 0.%{increment}.%{_revision}
%endif
%if %{build_branch}
%define rpm_release 0.%{increment}.%{_revision}
%endif
%if %{build_release}
%define rpm_release 1
%endif


Name:		logitechmediaserver
Packager:	Logitech - please visit www.mysqueezebox.com/support
Version:	%{_version}
Release:	%{rpm_release}
Summary:        Logitech Media Server

Group:		System Environment/Daemons          
License:	GPL and proprietary        
URL:		http://www.mysqueezebox.com            
Source0:	%{src_basename}.tgz
Source1:	squeezeboxserver.config
Source2:	squeezeboxserver.init
Source3:	squeezeboxserver.logrotate
Source4:	squeezeboxserver.service
Source5:	README.systemd
BuildRoot:	%{_tmppath}/%{name}-%{version}-buildroot
Vendor:		Logitech


Requires:	perl >= 5.10.0
Recommends:     perl(IO::Socket::SSL)
Obsoletes:	squeezeboxserver, squeezecenter, slimserver, SliMP3
AutoReqProv:	no

BuildArch:	noarch       

%description
Logitech Media Server powers the Squeezebox, Transporter and SLIMP3 network music 
players and is the best software to stream your music to any software MP3 
player. It supports MP3, AAC, WMA, FLAC, Ogg Vorbis, WAV and more!
As of version 7.7 it also supports UPnP clients, serving pictures and movies too!

%prep
%setup -q -n %{src_basename}


%build
# Rearrange some documentation
mv lib/README README.lib
mv HTML/README.txt README.HTML

# Remove mysqld and other unneeded files
rm -rf Bin/darwin
rm -rf Bin/i386-freebsd-64int
rm -rf Bin/MSWin32-x86-multi-thread
rm -rf CPAN/arch/*/darwin-thread-multi-2level
rm -rf CPAN/arch/*/sparc-linux
rm -rf CPAN/arch/*/i386-freebsd-64int
rm -rf CPAN/arch/*/MSWin32-x86-multi-thread

%install
rm -rf $RPM_BUILD_ROOT

# FHS compatible directory structure
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/init.d
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/squeezeboxserver
mkdir -p $RPM_BUILD_ROOT%{_usr}/lib/perl5/vendor_perl
mkdir -p $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
mkdir -p $RPM_BUILD_ROOT%{_usr}/libexec
mkdir -p $RPM_BUILD_ROOT%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/cache
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/Plugins
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin
mkdir -p $RPM_BUILD_ROOT%{_var}/log/squeezeboxserver

# Copy over the files
cp -Rp Bin $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp CPAN $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp Firmware $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp Graphics $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp HTML $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp IR $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp lib $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -Rp Slim $RPM_BUILD_ROOT%{_usr}/lib/perl5/vendor_perl
cp -Rp SQL $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -p revision.txt $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -p strings.txt $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -p icudt46*.dat $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -p icudt58*.dat $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver
cp -p slimserver.pl $RPM_BUILD_ROOT%{_usr}/libexec/squeezeboxserver
cp -p scanner.pl $RPM_BUILD_ROOT%{_usr}/libexec/squeezeboxserver-scanner
cp -p cleanup.pl $RPM_BUILD_ROOT%{_usr}/sbin/squeezeboxserver-cleanup

# Create symlink to 3rd Party Plugins
ln -s %{_var}/lib/squeezeboxserver/Plugins \
	$RPM_BUILD_ROOT%{_datadir}/squeezeboxserver/Plugins

# Install init, configuration and log files
install -Dp -m755 %SOURCE1 $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig/squeezeboxserver
install -Dp -m755 %SOURCE2 $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver/squeezeboxserver.SYSV
install -Dp -m644 %SOURCE3 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/squeezeboxserver
install -Dp -m644 %SOURCE4 $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver/squeezeboxserver.service
install -Dp -m644 %SOURCE5 $RPM_BUILD_ROOT%{_datadir}/squeezeboxserver/README.systemd
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/server.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/log.conf
cp -p convert.conf $RPM_BUILD_ROOT%{_sysconfdir}/squeezeboxserver
cp -p modules.conf $RPM_BUILD_ROOT%{_sysconfdir}/squeezeboxserver
cp -p types.conf $RPM_BUILD_ROOT%{_sysconfdir}/squeezeboxserver
touch $RPM_BUILD_ROOT%{_var}/log/squeezeboxserver/perfmon.log 
touch $RPM_BUILD_ROOT%{_var}/log/squeezeboxserver/server.log 
touch $RPM_BUILD_ROOT%{_var}/log/squeezeboxserver/scanner.log 
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/cli.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/datetime.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/infobrowser.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/itunes.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/musicmagic.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/podcast.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/radiotime.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/randomplay.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/rescan.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/rssnews.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezeboxserver/prefs/plugin/state.prefs

# Create symlink to server prefs file
ln -s %{_var}/lib/squeezeboxserver/prefs/server.prefs \
	$RPM_BUILD_ROOT%{_sysconfdir}/squeezeboxserver/server.conf


%clean
rm -rf $RPM_BUILD_ROOT


%pre
test -f /tmp/squeezerpmdebug && set -x
getent group squeezeboxserver >/dev/null || groupadd -r squeezeboxserver
getent passwd squeezeboxserver >/dev/null || \
useradd -r -g squeezeboxserver -d %{_datadir}/squeezeboxserver -s /sbin/nologin \
    -c "Logitech Media Server" squeezeboxserver

exit 0


%post
function parseSysconfigSqueezeboxserver {

	# Some simple checks on the /etc/sysconfig/squeezeboxserver
	# No guarantees that these checks will catch all changes that may have 
	# been made that might have an impact on the move to systemd
	. %{_sysconfdir}/sysconfig/squeezeboxserver
	if [ "$SQUEEZEBOX_USER" != "squeezeboxserver" ] ; then
		echo "################################################################################"
		echo "You seem to have changed the user id used to run squeezeboxserver."
		echo "Please read %{_datadir}/squeezeboxserver/README.systemd to find out"
		echo "how transfer this change to the new systemd set-up."
	fi

	# Check if any additions to the SQUEEZEBOX_ARGS variable have been made.
	# Do that by filter out the ones we know should be there.
	extra=`echo $SQUEEZEBOX_ARGS |tr " " "\n"|grep -v -E "(--daemon|--prefsdir|--logdir|--cachedir|--charset)"` || :
	if [ -n "$extra" ] ; then
		echo "################################################################################"
		echo "You seem to have changed the SQUEEZEBOX_ARGS variable in %{_sysconfdir}/sysconfig/squeezeboxserver."
		echo "Please read %{_datadir}/squeezeboxserver/README.systemd to find out"
                echo "how transfer this change to the new systemd set-up."
	fi
}

function setSelinux {

	# The following commands will extract mysql port and cachedir from the prefs file
	# I'm not sure if that's the right thing to do so have left them disabled for now
	#MYSQLPORT=`perl -ne  'if (/^dbsource:.*port=(\d+)[^\d]*/) {print "$1"}'  /etc/squeezeboxserver/server.prefs`
	#[ -z "$MYSQLPORT" ] && MYSQLPORT=9092
	#CACHEDIR=`awk '/^cachedir/ {print $2}' /etc/squeezeboxserver/server.prefs`
	#[ -z "$CACHEDIR" ] && CACHEDIR=9092
	MYSQLPORT=9092
	CACHEDIR=%{_var}/lib/squeezeboxserver/cache

	# Add SELinux contexts
	# We need this irrespective of whether it is a systemd or SYSV server.
	if [ -x /usr/sbin/selinuxenabled ] ; then
		if /usr/sbin/selinuxenabled ; then
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage port -a -t mysqld_port_t -p tcp ${MYSQLPORT} > /dev/null 2>&1
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -a -t mysqld_db_t "${CACHEDIR}(/.*)?" > /dev/null 2>&1
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -a -t mysqld_var_run_t "${CACHEDIR}/squeezeboxserver-mysql.sock" > /dev/null 2>&1
			/sbin/restorecon -R ${CACHEDIR} > /dev/null 2>&1
		fi
	fi
}

function setSYSV {

	# This is a SYSV server. Copy SYSV script to the correct place.
	cp -p %{_datadir}/squeezeboxserver/squeezeboxserver.SYSV %{_sysconfdir}/init.d/squeezeboxserver >/dev/null 2>&1 || :
        
	#SME Server uses runlevel 7
	if [ -f /etc/e-smith-release -a -d /etc/rc7.d ] ; then
		ln -sf %{_sysconfdir}/init.d/squeezeboxserver /etc/rc7.d/S80squeezeboxserver >/dev/null 2>&1 || :
		db configuration set squeezeboxserver service status enabled >/dev/null 2>&1 || :
	fi
	/sbin/chkconfig --add squeezeboxserver >/dev/null 2>&1 || :
	/sbin/service squeezeboxserver restart >/dev/null 2>&1 || :
}

function setSystemd {

	# I believe the latest version of SME Server still use SYSV,
	# any future releases will probably not use SYSV, here I will
	# just assume that they will use systemd in the standard way
	# (is there any other way?)

	if [ -n "$migrate" ] ; then
		# If we currently are running through a SYSV script. First stop 
 		/sbin/service squeezeboxserver stop >/dev/null 2>&1 || :
		/sbin/chkconfig --del squeezeboxserver >/dev/null 2>&1 || :
		# We should not remove the old SYSV init file. The RPM
		# package will take care of this when we do an upgrade.
	fi

	cp -p %{_datadir}/squeezeboxserver/squeezeboxserver.service /usr/lib/systemd/system/squeezeboxserver.service || :
	/usr/bin/systemctl daemon-reload >/dev/null 2>&1 || :
        /usr/bin/systemctl enable  squeezeboxserver.service >/dev/null 2>&1 || :
        /usr/bin/systemctl restart squeezeboxserver.service >/dev/null 2>&1 || :
}

test -f /tmp/squeezerpmdebug && set -x

# Source /etc/os-release to find out what kind of system we are on.
# We will use ID_LIKE from this file
. /etc/os-release || :

# If the SYSV init script exists and the server uses systemd
# then migrate to systemd unit file.
if [ -e /etc/init.d/squeezeboxserver -a -x /usr/bin/systemctl ] ; then
	migrate=true
fi

# If CentOS/RedHat/Fedora, handle selinux
if [ -f /etc/redhat-release -o -n "$(echo $ID_LIKE |/usr/bin/grep -i -E '(centos|redhat|rhel|fedora)')" ] ; then
        setSelinux
fi

if [ ! -x /usr/bin/systemctl ] ; then
	setSYSV
else
	setSystemd
fi

PORT=`awk '/^httpport/ {print $2}' %{_var}/lib/squeezeboxserver/prefs/server.prefs`
[ -z "$PORT" ] && PORT=9000
HOSTNAME=`uname -n`
if [ -n "$migrate" ] ; then
	echo "Squeezeboxserver was migrated from old style SYSV to systemd start-up."
	parseSysconfigSqueezeboxserver || :
fi
echo "Point your web browser to http://$HOSTNAME:$PORT/ to configure Logitech Media Server."

%preun
test -f /tmp/squeezerpmdebug && set -x
function unsetSelinux {

	# Remove SELinux contexts
	MYSQLPORT=9092
	CACHEDIR=%{_var}/lib/squeezeboxserver/cache
	if [ -x /usr/sbin/selinuxenabled ] ; then
		if /usr/sbin/selinuxenabled; then
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage port -d -t mysqld_port_t -p tcp ${MYSQLPORT}
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -d -t mysqld_db_t "${CACHEDIR}(/.*)?"
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -d -t mysqld_var_run_t "${CACHEDIR}/squeezeboxserver-mysql.sock"
			/sbin/restorecon -R ${CACHEDIR}
		fi
	fi

}

function unsetSYSV {

	/sbin/service squeezeboxserver stop >/dev/null 2>&1 || :
	if [ -f /etc/e-smith-release -a -d /etc/rc7.d ] ; then
		#SME Server uses runlevel 7
		db configuration set squeezeboxserver service status disabled >/dev/null 2>&1 || :
		rm /etc/rc7.d/S80squeezeboxserver || :
	fi
       	/sbin/chkconfig --del squeezeboxserver >/dev/null 2>&1 || :
	# Remove the SYSV file we copied in the post script.
	rm -f /etc/init.d/squeezeboxserver || :

}

function unsetSystemd {

	# systemd
        /usr/bin/systemctl unmask squeezeboxserver.service >/dev/null 2>&1 || :
	/usr/bin/systemctl disable squeezeboxserver.service >/dev/null 2>&1 || :
	/usr/bin/systemctl stop squeezeboxserver.service >/dev/null 2>&1 || :
	# Remove the unit file we copied in the post script.
	rm -f /usr/lib/systemd/system/squeezeboxserver.service || :
	/usr/bin/systemctl daemon-reload >/dev/null 2>&1 || :

}

. /etc/os-release || :

if [ "$1" -eq "0" ] ; then
	# If not upgrading
	
	# First stop and removethe start-up script/unit file.
	if [ ! -x /usr/bin/systemctl ] ; then

		unsetSYSV

	else 
	
		unsetSystemd

	fi

	# If CentOS/Fedora/RedHat, remove selinux settings
	if [ -f /etc/redhat-release -o -n "$(echo $ID_LIKE |/usr/bin/grep -i -E '(centos|redhat|rhel|fedora)')" ] ; then

		unsetSelinux

	fi

fi


%postun


%files
%defattr(-,root,root,-)

# Documentation files
%doc Changelog*.html License.* README.lib README.HTML

# Main files
%{_usr}/lib/perl5/vendor_perl/Slim
%{_datadir}/squeezeboxserver

# Empty directories
%attr(0755,squeezeboxserver,squeezeboxserver) %dir %{_var}/lib/squeezeboxserver
%attr(0755,squeezeboxserver,squeezeboxserver) %dir %{_var}/lib/squeezeboxserver/cache
%attr(0755,squeezeboxserver,squeezeboxserver) %dir %{_var}/lib/squeezeboxserver/Plugins

# Executables
%{_usr}/libexec/squeezeboxserver
%{_usr}/libexec/squeezeboxserver-scanner
%{_usr}/sbin/squeezeboxserver-cleanup

# Log files
%attr(0755,squeezeboxserver,squeezeboxserver) %dir %{_var}/log/squeezeboxserver
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/log/squeezeboxserver/perfmon.log
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/log/squeezeboxserver/server.log
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/log/squeezeboxserver/scanner.log

# Configuration files and init script
%dir %{_sysconfdir}/squeezeboxserver
%attr(0755,squeezeboxserver,squeezeboxserver) %dir %{_var}/lib/squeezeboxserver/prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %config(noreplace) %{_var}/lib/squeezeboxserver/prefs/server.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/log.conf
%attr(0755,squeezeboxserver,squeezeboxserver) %dir %{_var}/lib/squeezeboxserver/prefs/plugin
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/cli.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/datetime.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/infobrowser.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/itunes.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/musicmagic.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/podcast.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/radiotime.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/randomplay.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/rescan.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/rssnews.prefs
%attr(0644,squeezeboxserver,squeezeboxserver) %ghost %{_var}/lib/squeezeboxserver/prefs/plugin/state.prefs
%config(noreplace) %{_sysconfdir}/squeezeboxserver/server.conf
%attr(0644,squeezeboxserver,squeezeboxserver) %config(noreplace) %{_sysconfdir}/squeezeboxserver/convert.conf
%attr(0644,squeezeboxserver,squeezeboxserver) %config(noreplace) %{_sysconfdir}/squeezeboxserver/modules.conf
%attr(0644,squeezeboxserver,squeezeboxserver) %config(noreplace) %{_sysconfdir}/squeezeboxserver/types.conf
%attr(0644,root,root) %config(noreplace) %{_sysconfdir}/sysconfig/squeezeboxserver
%config(noreplace) %{_sysconfdir}/logrotate.d/squeezeboxserver



%changelog
* Sat Apr 24 2021 Johan S.
- Added a weak dependency for perl(IO::Socket:SSL). This package is almost 
  always needed now a days. Zypper and dnf will pull in this package if it is
  available in the repositories defined on the server. rpm will not evaluate the
  weak dependency and neith will yum on pre CentOS/RHEL 8.0 systems.
* Sun Apr 11 2021 Johan S.
- Added a systemd Unit file to the RMP package. The file is based on the systemd
  unit file developed by mw9 & tomscytale for the Debian package.
- Amendedments to the postinstall and preuninstall scripts to handle which
  start-up method to install and uninstall, SYSV or systemd. Squeezebox server
  installations running on systemd servers will be migrated to systemd start-up
  when the logitechmediaserver RPM is upgraded.
- Added use of PERL5LIB in SYSV init script and systemd unit file, making sure
  that /usr/lib/perl5/site_perl is the first location where the squeezebox 
  executable search for its needed perl modules. This will remove the need to 
  create symbolic links to /usr/lib/perl5/vendor_perl on systems where perl 
  expects the modules ina different location.
- Remove the creation of symbolic link in /usr/lib/perl5/site_perl for SUSE
  distribution in the post install script as it is no longer needed (see 
  previous point).
- Added a function in the post install script to parse 
  /etc/sysconfig/squeezeboxserver to see if any changes have been done to the
  script that will not be picked up by the systemd unit file. If such changes
  are found a warning is issued at the end of the installation procedure. This
  parsing of the sysconfg file is only done when the installation is migrated 
  from SYSV to systemd.

* Wed Oct 31 2007 Robin Bowes <robin@robinbowes.com>
- Fix SELinux contexts

* Fri Oct 26 2007 Mark Miksis <aka Fletch>
- Make RPM work "out of the box" with SUSE

* Mon Oct 22 2007 Mark Miksis <aka fletch>
- Rewrite for conversion to SqueezeCenter 7.0
	- Rename to squeezeboxserver and obsolete slimserver
	- Compatible with FHS and Fedora Packaging Guidelines
	- Use system copy of flac, mysqld and sox
	- Add condrestart option and support for logrotate
	- Build from the public tarball, not the munged makerelease.pl one
	- Simplify and rewrite %pre and %post scriptlets

* Tue Oct 16 2007 andy
- Removed deps on perl-XML-Parser and perl-Digest-SHA1

* Mon Apr 11 2005 dsully
- Make the RPM more SuSE friendly.
- Fix an error with printing the port number on install/upgrade. (bug 974)

* Thu Nov 6 2003 dean
- Renaming slimd to slimserver

* Mon Sep 15 2003 kdf
- Patch submitted by many for custom port message on install
- remove /tmp/slimd.log if it exists, avoid server crash if its locked.

* Fri Aug 1 2003 kdf
- Change user to slim, install to /usr/local/slimd for consistency
- Copy old slimp3.pref if it exists and slimd.conf is zero length (new)

* Thu May 22 2003 dean
Victor Brilon submitted a patch:
- Got rid of the -r param. On RedHat this creates a system account w/a 
UID lower than value of UID_MIN. I don't see why we need to do this as 
the slimp3 user is not a priviledged user. Also, with this param, the -d 
flag will never create a home dir for security reasons.

- Got rid of the -s flag as this will force the system to use the 
default shell for the user.

- Also with useradd, if a passwd is not specified (which is exactly what 
we're doing), the default action is to lock the account so you can't 
login into it. This should work ok as we can still su into it to start 
the slimp3 player.

- The slimp3 directory hierarchy should be owned by the slimp3 user not 
by root. Changed that as well. This should prevent some of the problems 
people were having with saving playlists and such.

* Mon Feb 10 2003 DV <datavortex@datavortex.net>
- Remove tag database on full uninstall.  db.pag gets big.
- Fixed postinstall substitution
- Remove nondefault user and group

* Sun Feb 09 2003	Mike Arnold <mike@razorsedge.org>
- Cleaned up DV's changes to the preinstall script.
- Added %config(noreplace) to /etc/sysconfig/slimp3.
- Fixed two changes in the postinstall script that broke relocation.

* Thu Oct 24 2002   DV <datavortex@datavortex.net>
- changed account to a system account and shell to nologin.
- don't add user with default name if the admin changed it.

* Tue Oct 22 2002	Mike Arnold <mike@razorsedge.org>
- Fixed a problem with doing a package "upgrade" and losing the
  passwd entry for the slimp3 user in %preun and %postun.
- Made sure an existing /etc/slimp3.pref was not replaced by a newer package.
- Got rid of all the commented, tarball-removal stuff in %pre.
- Beautified the spec file for final release.

* Sun Oct 20 2002   Dean Blackketter <dean@slimdevices.com>
- Mike Arnold told me to take out the postun directive that removes the
  passwd entry to fix upgrades.

* Tue Oct 01 2002	Mike Arnold <mike@razorsedge.org>
- Made the slimp3 user's $HOME be in the correct place even with
  a relocatable package.

* Wed Sep 11 2002	Dean Blackketter <dean@slimdevices.com>
- Made the default install back to /usr/local/bin instead of /opt

* Sun Sep 08 2002	Mike Arnold <mike@razorsedge.org>
- Made the RPM relocatable for those who do not want to use /opt
  including a %post hack to mod /etc/sysconfig/slimp3
- Made sure slimp3.pl was chmod +x, even if the tarball was wrong
- Cleaned up the BUILD_DIR after the rpms are built
- Changed localhost to "uname -n" in post-install commandline echo
- Disabled the deletion of old (pre-RPM) files as the procs may
  still be running. Should we just assume no preexisting installs?
- Pulled _topdir out and let the build system or user specify it.

* Wed Sep 04 2002	Dean Blackketter <dean@slimdevices.com>
- Disabling the shutdown of old (pre-RPM) processes.
- Added AutoReqProv: no, because all we really need is perl
- Disabled the documentation install until we have some better docs.
  (until then, use the built-in documentation, available via the web interface)

* Mon Sep 02 2002	Mike Arnold <mike@razorsedge.org>
- Changed the slimp3dir to /opt as this is where "packages" should go
- Added an external startup config file in /etc/sysconfig
- Added documentation to the RPM
- Kept %postun from deleteing the %config file as rpm takes care of this
- Changed software group to System Environment/Daemons
- Added a nice description
- Added %clean

* Wed Aug 28 2002	Victor Brilon <victor@vail.net>
- First release
