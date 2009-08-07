# The following macros can either be defined here or passed into rpmbuild as macros
# This is required:
# %%define _version 7.4
# One (and only one) of the following is required:
# %%define _with_trunk 1
# %%define _with_branch 1
# %%define _with_release 1
# These are required with _with_trunk or _with_branch
# %%define _src_date 2007-12-07
# %%define _rpm_date 20071207
# The following is required with _with_branch
# %%define _branch 7.4

%define increment 1

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


Name:		squeezeboxserver
Packager:	Slim Devices/Logitech <support@slimdevices.com>
Version:	%{_version}
Release:	%{rpm_release}
Summary:        SqueezeBox Server

Group:		System Environment/Daemons          
License:	GPL and proprietary        
URL:		http://www.slimdevices.com            
Source0:	%{src_basename}.tgz
Source1:	squeezebox.config
Source2:	squeezebox.init
Source3:	squeezebox.logrotate
BuildRoot:	%{_tmppath}/%{name}-%{version}-buildroot
Vendor:		Logitech


Requires:	/usr/bin/mysqld_safe, perl >= 5.8.3
Obsoletes:	slimserver, SliMP3
AutoReqProv:	no

BuildArch:	noarch       

%description
SqueezeBox Server powers the Squeezebox, Transporter and SLIMP3 network music 
players and is the best software to stream your music to any software MP3 
player. It supports MP3, AAC, WMA, FLAC, Ogg Vorbis, WAV and more!


%prep
%setup -q -n %{src_basename}


%build
# Rearrange some documentation
mv lib/README README.lib
mv HTML/README.txt README.HTML

# Remove mysqld and other unneeded files
rm MySQL/COPYING
rm MySQL/README
rm MySQL/errmsg.*
rm Bin/i386-linux/mysqld
rm -rf Bin/darwin
rm -rf Bin/powerpc-hardhat-linux
rm -rf Bin/MSWin32-x86-multi-thread
rm -rf CPAN/arch/5.8/darwin-thread-multi-2level
rm -rf CPAN/arch/5.8/sparc-linux
rm -rf CPAN/arch/5.10/darwin-thread-multi-2level
rm -rf CPAN/arch/5.10/MSWin32-x86-multi-thread

%install
rm -rf $RPM_BUILD_ROOT

# FHS compatible directory structure
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/init.d
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/squeezebox
mkdir -p $RPM_BUILD_ROOT%{_usr}/lib/perl5/vendor_perl
mkdir -p $RPM_BUILD_ROOT%{_datadir}/squeezebox
mkdir -p $RPM_BUILD_ROOT%{_usr}/libexec
mkdir -p $RPM_BUILD_ROOT%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezebox/cache
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezebox/Plugins
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin
mkdir -p $RPM_BUILD_ROOT%{_var}/log/squeezebox

# Copy over the files
cp -Rp Bin $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp CPAN $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp Firmware $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp Graphics $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp HTML $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp IR $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp lib $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp MySQL $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -Rp Slim $RPM_BUILD_ROOT%{_usr}/lib/perl5/vendor_perl
cp -Rp SQL $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -p revision.txt $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -p strings.txt $RPM_BUILD_ROOT%{_datadir}/squeezebox
cp -p slimserver.pl $RPM_BUILD_ROOT%{_usr}/libexec/squeezebox
cp -p scanner.pl $RPM_BUILD_ROOT%{_usr}/libexec/squeezebox-scanner
cp -p cleanup.pl $RPM_BUILD_ROOT%{_usr}/sbin/squeezebox-cleanup

# Create symlink to 3rd Party Plugins
ln -s %{_var}/lib/squeezebox/Plugins \
	$RPM_BUILD_ROOT%{_datadir}/squeezebox/Plugins

# Install init, configuration and log files
install -Dp -m755 %SOURCE1 $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig/squeezebox
install -Dp -m755 %SOURCE2 $RPM_BUILD_ROOT%{_sysconfdir}/init.d/squeezebox
install -Dp -m644 %SOURCE3 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/squeezebox
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/server.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/log.conf
cp -p convert.conf $RPM_BUILD_ROOT%{_sysconfdir}/squeezebox
cp -p modules.conf $RPM_BUILD_ROOT%{_sysconfdir}/squeezebox
cp -p types.conf $RPM_BUILD_ROOT%{_sysconfdir}/squeezebox
touch $RPM_BUILD_ROOT%{_var}/log/squeezebox/perfmon.log 
touch $RPM_BUILD_ROOT%{_var}/log/squeezebox/server.log 
touch $RPM_BUILD_ROOT%{_var}/log/squeezebox/scanner.log 
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/cli.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/datetime.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/infobrowser.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/itunes.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/musicmagic.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/podcast.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/radiotime.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/randomplay.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/rescan.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/rssnews.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/squeezebox/prefs/plugin/state.prefs

# Create symlink to server prefs file
ln -s %{_var}/lib/squeezebox/prefs/server.prefs \
	$RPM_BUILD_ROOT%{_sysconfdir}/squeezebox/server.conf


%clean
rm -rf $RPM_BUILD_ROOT


%pre
getent group squeezebox >/dev/null || groupadd -r squeezebox
getent passwd squeezebox >/dev/null || \
useradd -r -g squeezebox -d %{_datadir}/squeezebox -s /sbin/nologin \
    -c "SqueezeBox Server" squeezebox
exit 0


%post
# The following commands will extract mysql port and cachedir from the prefs file
# I'm not sure if that's the right thing to do so have left them disabled for now
#MYSQLPORT=`perl -ne  'if (/^dbsource:.*port=(\d+)[^\d]*/) {print "$1"}'  /etc/squeezebox/server.prefs`
#[ -z "$MYSQLPORT" ] && MYSQLPORT=9092
#CACHEDIR=`awk '/^cachedir/ {print $2}' /etc/squeezebox/server.prefs`
#[ -z "$CACHEDIR" ] && CACHEDIR=9092
MYSQLPORT=9092
CACHEDIR=%{_var}/lib/squeezebox/cache
if [ -f /etc/redhat-release ] ; then
	# Add SELinux contexts
	if [ -x /usr/sbin/selinuxenabled ] ; then
		if /usr/sbin/selinuxenabled ; then
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage port -a -t mysqld_port_t -p tcp ${MYSQLPORT} > /dev/null 2>&1
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -a -t mysqld_db_t "${CACHEDIR}(/.*)?"
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -a -t mysqld_var_run_t "${CACHEDIR}/squeezebox-mysql.sock"
			/sbin/restorecon -R ${CACHEDIR}
		fi
	fi
	/sbin/chkconfig --add squeezebox
	if [ -f /etc/e-smith-release -a -d /etc/rc7.d ] ; then
		#SME Server uses runlevel 7
		ln -s /etc/init.d/squeezebox /etc/rc7.d/S80squeezebox
		db configuration set squeezebox service status enabled
	fi
	/sbin/service squeezebox restart >/dev/null 2>&1 || :
elif [ -f /etc/SuSE-release ] ; then
	/usr/lib/lsb/install_initd /etc/init.d/squeezebox
	/etc/init.d/squeezebox restart  > /dev/null 2>&1
fi
PORT=`awk '/^httpport/ {print $2}' %{_var}/lib/squeezebox/prefs/server.prefs`
[ -z "$PORT" ] && PORT=9000
HOSTNAME=`uname -n`
echo "Point your web browser to http://$HOSTNAME:$PORT/ to configure SqueezeBox Server."


%preun
MYSQLPORT=9092
CACHEDIR=%{_var}/lib/squeezebox/cache
if [ "$1" -eq "0" ] ; then
	# If not upgrading
	if [ -f /etc/redhat-release ] ; then
		/sbin/service squeezebox stop >/dev/null 2>&1 || :
		if [ -f /etc/e-smith-release -a -d /etc/rc7.d ] ; then
			#SME Server uses runlevel 7
			db configuration set squeezebox service status disabled
			rm /etc/rc7.d/S80squeezebox
		fi
        	/sbin/chkconfig --del squeezebox
		# Remove SELinux contexts
		if [ -x /usr/sbin/selinuxenabled ] ; then
			if /usr/sbin/selinuxenabled; then
				[ -x /usr/sbin/semanage ] && /usr/sbin/semanage port -d -t mysqld_port_t -p tcp ${MYSQLPORT}
				[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -d -t mysqld_db_t "${CACHEDIR}(/.*)?"
				[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -d -t mysqld_var_run_t "${CACHEDIR}/squeezebox-mysql.sock"
				/sbin/restorecon -R ${CACHEDIR}
			fi
		fi
	elif [ -f /etc/SuSE-release ] ; then
		/etc/init.d/squeezebox stop  > /dev/null 2>&1
		/usr/lib/lsb/remove_initd /etc/init.d/squeezebox
	fi
fi


%postun


%files
%defattr(-,root,root,-)

# Documentation files
%doc Changelog*.html Installation.txt License.* README.lib README.HTML

# Main files
%{_usr}/lib/perl5/vendor_perl/Slim
%{_datadir}/squeezebox

# Empty directories
%attr(0755,squeezebox,squeezebox) %dir %{_var}/lib/squeezebox
%attr(0755,squeezebox,squeezebox) %dir %{_var}/lib/squeezebox/cache
%attr(0755,squeezebox,squeezebox) %dir %{_var}/lib/squeezebox/Plugins

# Executables
%{_usr}/libexec/squeezebox
%{_usr}/libexec/squeezebox-scanner
%{_usr}/sbin/squeezebox-cleanup

# Log files
%attr(0755,squeezebox,squeezebox) %dir %{_var}/log/squeezebox
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/log/squeezebox/perfmon.log
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/log/squeezebox/server.log
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/log/squeezebox/scanner.log

# Configuration files and init script
%dir %{_sysconfdir}/squeezebox
%attr(0755,squeezebox,squeezebox) %dir %{_var}/lib/squeezebox/prefs
%attr(0644,squeezebox,squeezebox) %config(noreplace) %{_var}/lib/squeezebox/prefs/server.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/log.conf
%attr(0755,squeezebox,squeezebox) %dir %{_var}/lib/squeezebox/prefs/plugin
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/cli.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/datetime.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/infobrowser.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/itunes.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/musicmagic.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/podcast.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/radiotime.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/randomplay.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/rescan.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/rssnews.prefs
%attr(0644,squeezebox,squeezebox) %ghost %{_var}/lib/squeezebox/prefs/plugin/state.prefs
%attr(0644,squeezebox,squeezebox) %{_sysconfdir}/squeezebox/server.conf
%attr(0644,squeezebox,squeezebox) %config(noreplace) %{_sysconfdir}/squeezebox/convert.conf
%attr(0644,squeezebox,squeezebox) %config(noreplace) %{_sysconfdir}/squeezebox/modules.conf
%attr(0644,squeezebox,squeezebox) %config(noreplace) %{_sysconfdir}/squeezebox/types.conf
%{_sysconfdir}/init.d/squeezebox
%attr(0644,root,root) %config(noreplace) %{_sysconfdir}/sysconfig/squeezebox
%config(noreplace) %{_sysconfdir}/logrotate.d/squeezebox



%changelog
* Wed Oct 31 2007 Robin Bowes <robin@robinbowes.com>
- Fix SELinux contexts

* Fri Oct 26 2007 Mark Miksis <aka Fletch>
- Make RPM work "out of the box" with SUSE

* Mon Oct 22 2007 Mark Miksis <aka fletch>
- Rewrite for conversion to SqueezeCenter 7.0
	- Rename to squeezebox and obsolete slimserver
	- Compatible with FHS and Fedora Packaging Guidelines
	- Use system copy of flac, mysqld and sox
	- Add condrestart option and support for logrotate
	- Build from the public tarball, not the munged makerelease.pl one
	- Simplify and rewrite %pre and %post scriptlets

* Tue Oct 16 2007 andy
- Removed deps on perl-XML-Parser and perl-Digest-SHA1

* Tue Apr 11 2005 dsully
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
