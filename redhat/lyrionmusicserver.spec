# The following macros can either be defined here or passed into
# rpmbuild with the --define option.
#
# This is required:
# %%define _version 9.2.0
#
# The following is required with trunk or branch:
# %%define _revision 1781670901
#
# One of the following may be specified with rpmbuild's --with option.
# The default is release.
%bcond trunk 0
%bcond branch 0
%bcond release %{without trunk} && %{without branch}

%if ! %{defined src_basename}
%global src_basename lyrionmusicserver
%endif

# As from version 9.0.0 the logitech media server has been re-branded 
# to Lyrion Music Server. It was decided to also properly re-name all
# components in the RPM package that have been using the string
# squeezeboxserver for the executables and for locations in the file
# systems. It was also decided to use new user and group names to own 
# the files and to run the daemons.
#
# The new user id is lyrionmusicserver
# Then new group is lyrionmusicserver
#
# And the string "lyrionmusicserver" will be used to name executables,
# systemd unid and the SYSV init script and all the locations in the file
# systems where previously "squeezeboxserver" was used.
#
# This change is rather fundamental and requires some extra handling
# in the pre and post scripts of the RPM package.
#
# If the upgrade/installation of Lyrion Music Server is replacing
# a Logitech Media Server installation (or an early development 
# installation of the Lyrion Music Server), i.e. 9.0.0), then the RPM 
# will attempt to migrate the old configuration to the new Lyrion
# Music server. This migration will only be attempted if the old 
# configuration is in the default locations AND if the location
# /var/lib/lyrionmusicserver does not exist.

%define increment 1

# Turn off striping of binaries
%global __strip /bin/true

# don't terminate build due to binaries
%global _binaries_in_noarch_packages_terminate_build 0

%if %{with trunk} || %{with branch}
%define rpm_release 0.%{increment}.%{_revision}
%elif %{with release}
%define rpm_release 1
%else
%{error:One of the conditonals trunk, branch or release is required}
%endif

# The variable src_basename  is passed to the build by the buildme.pl script.
# At the moment the value is lyrionmusicserver. We could thus use that 
# variable everywhere in the RPM spec file where we want to use that 
# string, like naming directories or files. But in the past it was for long
# period of times the case that the software used the name squeezeboxserver
# and the package was called logitechemediaserver. If this situation would
# arise again it would be inconvenient to use that variable to name all the 
# executables and file paths. Thus I add these extra variables her for this
# purpose.

%global userd lyrionmusicserver
%global groupd lyrionmusicserver
%global shortname lyrionmusicserver

Name:		%{src_basename}
Packager:	Lyrion Community
Version:	%{_version}
Release:	%{rpm_release}
Summary:        Lyrion Music Server

License:	GPL and proprietary
URL:		https://www.lyrion.org
%if %{with release}
Source0:	https://downloads.lms-community.org/LyrionMusicServer_v%{version}/%{src_basename}-%{version}.tgz
%else
Source0:	https://downloads.lms-community.org/nightly/%{src_basename}-%{version}-%{_revision}.tgz
%endif
Source1:	%{shortname}.config
Source3:	%{shortname}.logrotate
Source4:	%{shortname}.service
Source5:	README.systemd
Source6:        README.rebranding
Source7:        %{shortname}.preset
BuildRoot:	%{_tmppath}/%{name}-%{version}-buildroot

BuildRequires:   systemd-rpm-macros
Requires(pre):   /usr/bin/getent
Requires(pre):   /usr/bin/touch
Requires(pre):   /usr/sbin/groupadd
Requires(pre):   /usr/sbin/useradd
Requires(preun): /usr/bin/rm
Requires(post):  /usr/bin/cp
Requires(post):  /usr/bin/ln
Requires(post):  /usr/bin/mv
Requires(post):  /usr/bin/rm
Requires(post):  /usr/sbin/usermod
Requires(post):  /usr/bin/systemctl

# The following is needed to ensure that we get the right version of Perl.
# Check both for minumu and maximum versions.
# The perl(:VERSION) is for Red Hat flavours, and the perl >= is for SUSE flavours.
Requires: ((perl >= 5.22 or perl(:VERSION) >= 5.22) with ( perl < 5.43 or perl(:VERSION) < 5.43))

# The following Requires are a list of the Perl modules we know that we need.
# They are are required by Lyrion Music Server, but not shipped in the RPM 
# package. 
Requires:      perl(IO::Socket::SSL)
Requires:      perl(strict)
Requires:      perl(Config)
Requires:      perl(Socket)
Requires:      perl(FindBin)
Requires:      perl(lib)
Requires:      perl(Getopt::Long)
Requires:      perl(File::Path)
Requires:      perl(File::Copy)
Requires:      perl(File::Find)
Requires:      perl(POSIX)
Requires:      perl(Time::HiRes)
Requires:      perl(locale)
Requires:      perl(DynaLoader)
Requires:      perl(Sys::Hostname)
Requires:      perl(Devel::Peek)
Requires:      perl(I18N::LangTags)
Requires:      perl(subs)
Requires:      perl(Compress::Raw::Zlib)
Requires:      perl(Digest::SHA)

# Required for Unicode support on the fluorescent screens on old
# hardware players:
Recommends:    perl(Font::FreeType)

Requires:      logrotate

# For Red Hat based distributions, Recommend perl so that the Perl core is
# pulled in for use by LMS plugins. We use Recommends instead of Requires so
# that users can remove unneeded packages if they want too.
Recommends:    perl

%if "%{src_basename}" != "%{name}"
Provides:	%{src_basename} = %{version}-%{release}
%endif

Provides:	logitechmediaserver = %{version}-%{release}
Provides:	squeezeboxserver = %{version}-%{release}
Provides:	squeezecenter = %{version}-%{release}
Provides:	slimserver = %{version}-%{release}
Provides:	SliMP3 = %{version}-%{release}
Obsoletes:	logitechmediaserver < 9
Obsoletes:	squeezeboxserver < 7.7
Obsoletes:	squeezecenter < 7.4
Obsoletes:	slimserver < 7
Obsoletes:	SliMP3 < 5

AutoReqProv:	no

BuildArch:	noarch

%description
Lyrion Music Server powers the Squeezebox, Transporter and SLIMP3 network music
players and is the best software to stream your music to any software MP3
player. It supports MP3, AAC, WMA, FLAC, Ogg Vorbis, WAV and more!
As of version 7.7 it also supports UPnP clients.

%prep
%if %{with release}
%autosetup -n %{src_basename}-%{version}
%else
%autosetup -n %{src_basename}-%{version}-%{_revision}
%endif

cp %SOURCE5 %SOURCE6 ./


%build
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
mkdir -p $RPM_BUILD_ROOT%{_unitdir}
mkdir -p $RPM_BUILD_ROOT%{_presetdir}
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/%{shortname}
mkdir -p $RPM_BUILD_ROOT%{_usr}/lib/perl5/vendor_perl
mkdir -p $RPM_BUILD_ROOT%{_datadir}/%{shortname}
mkdir -p $RPM_BUILD_ROOT%{_usr}/libexec
mkdir -p $RPM_BUILD_ROOT%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/cache
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/Plugins
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin
mkdir -p $RPM_BUILD_ROOT%{_var}/log/%{shortname}

# Copy over the files
cp -Rp Bin $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp CPAN $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp Firmware $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp Graphics $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp HTML $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp IR $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp lib $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -Rp Slim $RPM_BUILD_ROOT%{_usr}/lib/perl5/vendor_perl
cp -Rp SQL $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -p revision.txt $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -p strings.txt $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -p icudt46*.dat $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -p icudt58*.dat $RPM_BUILD_ROOT%{_datadir}/%{shortname}
cp -p slimserver.pl $RPM_BUILD_ROOT%{_usr}/libexec/%{shortname}
cp -p scanner.pl $RPM_BUILD_ROOT%{_usr}/libexec/%{shortname}-scanner
cp -p cleanup.pl $RPM_BUILD_ROOT%{_usr}/libexec/%{shortname}-cleanup
cp -p gdresized.pl $RPM_BUILD_ROOT%{_usr}/libexec/%{shortname}-resized

# Create symlink to 3rd Party Plugins
ln -rs $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/Plugins \
	$RPM_BUILD_ROOT%{_datadir}/%{shortname}/Plugins

# Install service, configuration and log files
install -Dp -m644 %SOURCE1 $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig/%{shortname}
install -Dp -m644 %SOURCE3 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/%{shortname}
install -Dp -m644 %SOURCE4 $RPM_BUILD_ROOT%{_unitdir}/%{shortname}.service
install -Dp -m644 %SOURCE7 $RPM_BUILD_ROOT%{_presetdir}/50-%{shortname}.preset
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/server.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/log.conf
cp -p convert.conf $RPM_BUILD_ROOT%{_sysconfdir}/%{shortname}
cp -p modules.conf $RPM_BUILD_ROOT%{_sysconfdir}/%{shortname}
cp -p types.conf $RPM_BUILD_ROOT%{_sysconfdir}/%{shortname}
touch $RPM_BUILD_ROOT%{_var}/log/%{shortname}/perfmon.log
touch $RPM_BUILD_ROOT%{_var}/log/%{shortname}/server.log
touch $RPM_BUILD_ROOT%{_var}/log/%{shortname}/scanner.log
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/cli.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/datetime.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/infobrowser.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/itunes.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/musicmagic.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/podcast.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/radiotime.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/randomplay.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/rescan.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/rssnews.prefs
touch $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/plugin/state.prefs

# Create symlink to server prefs file
ln -rs $RPM_BUILD_ROOT%{_var}/lib/%{shortname}/prefs/server.prefs \
	$RPM_BUILD_ROOT%{_sysconfdir}/%{shortname}/server.conf


%pre -e
function checkConfigMigration () {

   test -f /tmp/squeezerpmdebug && set -x

   # We need to check if we are upgrading from the logitechmedia server
   # package to the lyrionmusic server package. If we are doing that
   # we must try to migrate the squeezeboxserver prefs files to
   # the new location of the lyrionmusicserver prefs files.
   # The prefs files must also be edited to replace the paths
   # pointing to the old squeezeboxserver prefs location
   # to the new locations of lyrionmusicserver.

   # Start with checking if there is a Lyrion Music server configuration file.
   # If there is, we will do no migration and just return immediately.
   if [ -f /var/lib/%{shortname}/prefs/server.prefs ]; then
      return 0
   fi

   # To check if an old logitechmediaserver RPM is currently installed, we check
   # if /usr/libexec/squeezeboxserver * AND * 
   # /var/lib/squeezeboxserver/prefs/server.prefs exist. Only if both these 
   # exist we will attempt a migration.
   # First see if currently the logitechmediaserver package is installed.

   if [ -f /usr/libexec/squeezeboxserver ]; then
     if [ -f /var/lib/squeezeboxserver/prefs/server.prefs ]; then

       # config should be migrated.
       /usr/bin/touch %{_tmppath}/migrateSqueezeboxserverConfig || :
 
       echo ""
       echo "#######################################################################"
       echo "** INFORMATION **"
       echo "Upgrading from squeezeboxserver to lyrionmusicserver!"
       echo "Will attempt to migrate the squeezeboxserver configuration in"
       echo "/var/lib/squeezeboxserver to the new lyrionmusicserver configuration"
       echo "in /var/lib/lyrionmusicserver."
       echo "#######################################################################"
       echo ""

     else 

       echo ""
       echo "#######################################################################"
       echo "** N O T E **"
       echo "Upgrading from a squeezeboxserver to a lyrionmusicserver!"
       echo "The squeezeboxserver configuration is not in the standard location."
       echo "You will have to either configure the Lyrion Music Server from scratch,"
       echo "or migrate your old configuration manually."
       echo "#######################################################################"
       echo ""
     fi
   fi

   return 0
}

test -f /tmp/squeezerpmdebug && echo "pre script"
test -f /tmp/squeezerpmdebug && set -x

# Create user and group if needed.
/usr/bin/getent group %{groupd} >/dev/null || /usr/sbin/groupadd -r %{groupd}
/usr/bin/getent passwd %{userd} >/dev/null || \
/usr/sbin/useradd -r -g %{groupd} -d %{_datadir}/%{shortname} -s /sbin/nologin \
    -c "Lyrion Music Server" %{userd}

# This function will set flags for the post script so that the post script will
# know if a migration from squeezeboxserver configuration to lyrionmusicserver
# configuration is necessary
checkConfigMigration

# The systemd RPM macros are not the same on Red Hat and SUSE
# distributions. The systemd_pre is only available on SUSE,
# and it is not needed on Red Hat distributions.
# Use the -e flag for the pre script, and escape the systemd_pre
# macro, so that the following is evaluated at runtime. This way a build
# created on of of the OS will also work on the other OS.
%%{?systemd_pre:%%{systemd_pre %{shortname}.service}}

exit 0


%post
function migrateSqueezeboxServerConfig {

   test -f /tmp/squeezerpmdebug && set -x

   # Make a safety copy of the empty lyrion config.
   if ! /usr/bin/cp -pr /var/lib/%{shortname} /var/lib/%{shortname}.bck >/dev/null 2>&1; then

      echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
      # Remove the safety copy (or whatever was created).
      /usr/bin/rm -fr /var/lib/%{shortname}.bck >/dev/null 2>&1 || :
      return 1

   fi

   if ! /usr/bin/cp -pr /var/lib/squeezeboxserver/* /var/lib/%{shortname} >/dev/null 2>&1; then

      echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
      # Restore the safety copy
      /usr/bin/rm -f -r /var/lib/%{shortname} >/dev/null 2>&1 || :
      /usr/bin/mv /var/lib/%{shortname}.bck /var/lib/%{shortname} >/dev/null 2>&1 || :
      return 1

   else

      if ! /usr/bin/find /var/lib/%{shortname} -type f -name "*.prefs" -exec /usr/bin/perl -i.pre-squeeze-to-lyrion -pe 's#/squeezeboxserver#/%{shortname}#' {} \; >/dev/null 2>&1; then
         echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
         # Restore the safety copy
         /usr/bin/rm -fr /var/lib/%{shortname} >/dev/null 2>&1 || :
         /usr/bin/mv /var/lib/%{shortname}.bck /var/lib/%{shortname} || :
         return 1
      fi


      if ! /usr/bin/chown -R %{userd}:%{groupd} /var/lib/%{shortname} >/dev/null 2>&1; then
         echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
         # Restore the safety copy
         /usr/bin/rm -fr /var/lib/%{shortname} >/dev/null 2>&1 || :
         /usr/bin/mv /var/lib/%{shortname}.bck /var/lib/%{shortname} || :
         return 1
      fi

   fi

   # Remove safety backup 
   /usr/bin/rm -fr /var/lib/%{shortname}.bck >/dev/null 2>&1 || :

   # Remove migration flag file
   /usr/bin/rm -f %{_tmppath}/migrateSqueezeboxserverConfig >/dev/null 2>&1 || :

   # Some plugin requires the user id that is used to run
   # the music server to be in specific groups. Thus, add
   # the user id lyrionmusicserver (%%{shortname} to the same
   # groups as the user id squeezeboxserver is in. This will
   # help those users who have added such plugins.
   groups=`groups squeezeboxserver |/usr/bin/perl -lane 'print foreach grep { not m/^(squeezeboxserver|\:)/   } @F'`
   for group in $groups; do
      /usr/sbin/usermod -aG $group %{shortname} 
   done

   # Print message about rebranding.
   echo ""
   echo "################################################################################"
   echo "NOTE"
   echo "From version 9.0.0 the Logitech Media Server has been rebranded Lyrion Music"
   echo "Server. All Components of the software have been re-branded from"
   echo "squeezeboxserver to lyrionmusicserver." 
   echo "To stop and start the software use:"
   echo "systemd start lyrionmusicserver"
   echo "and analogous for stop, status etc."
   echo ""
   echo ""
   echo "For more information, read %{_docdir}/%{shortname}/README.rebranding."
   echo "For more information, read %{_docdir}/%{shortname}/README.systemd."
   echo "################################################################################"
   echo ""

}

test -f /tmp/squeezerpmdebug && echo "post script"
test -f /tmp/squeezerpmdebug && set -x

# Check if we need to migrate a squeezeboxserver config to lyrion music server
if [ -f %{_tmppath}/migrateSqueezeboxserverConfig ]; then

   migrateSqueezeboxServerConfig

fi

# The following continues the initialisation of the service from
# the pre script. It will use the systemd.preset files to decide
# whether the service should be enabled or disabled by default.
%systemd_post %{shortname}.service 

# Here is an anomaly that I introduce to honour the long standing
# tradition that the Lyrion Music Server is started immediately
# if it is a first time installation. This of course contradicts
# the packaging rules of Fedora/SUSE et al
if [ "$1" -eq "1" ] ; then
   # This is a first time install.
   /usr/bin/systemctl daemon-reload || :
   /usr/bin/systemctl start %{shortname}.service || :

   PORT=`/usr/bin/perl -lane  'if ( /^httpport:/) {print $F[1]; exit}' %{_var}/lib/%{shortname}/prefs/server.prefs` || :
   [ -z "$PORT" ] && PORT=9000
   HOSTNAME=`uname -n` || :
   echo "Point your web browser to http://$HOSTNAME:$PORT/ to configure Lyrion Music Server." || :
else
   # The following should normally be done in the postun script, 
   # but as versions before 9.2 did not use the systemd_* macros to initialise
   # the service according to the packaging rules and the postun script was 
   # empty, we need to do this here.
   # This bit of code should eventually be removed when we think most of the 
   # users are on version 9.2 or newer.
   /usr/bin/systemctl try-restart %{shortname}.service || :
fi

exit 0


%preun
test -f /tmp/squeezerpmdebug && echo "preun script"
test -f /tmp/squeezerpmdebug && set -x

# Use this macro to ensure proper
# handling of the service.
%systemd_preun %{shortname}.service


%postun
test -f /tmp/squeezerpmdebug && echo "postun script"
test -f /tmp/squeezerpmdebug && set -x

# Use this macro to ensure proper
# handling of the service.
%systemd_postun_with_restart %{shortname}.service

exit 0


%files
%defattr(-,root,root,-)

# Documentation files
%license License.txt
%doc Changelog*.html
%doc README.md
%doc %{_datadir}/%{shortname}/HTML/Default/html/ext/README.TXT
%doc %{_datadir}/%{shortname}/HTML/README.txt
%doc %{_datadir}/%{shortname}/lib/README
%doc %{_usr}/lib/perl5/vendor_perl/Slim/DO_NOT_INSTALL_YOUR_PLUGINS_HERE.txt
%doc %{_usr}/lib/perl5/vendor_perl/Slim/Plugin/TT/README
%doc %{basename %SOURCE5}
%doc %{basename %SOURCE6}

# Main files
%{_usr}/lib/perl5/vendor_perl/Slim
%{_datadir}/%{shortname}

# Empty directories
%attr(0755,%{userd},%{groupd}) %dir %{_var}/lib/%{shortname}
%attr(0755,%{userd},%{groupd}) %dir %{_var}/lib/%{shortname}/cache
%attr(0755,%{userd},%{groupd}) %dir %{_var}/lib/%{shortname}/Plugins

# Executables
%{_usr}/libexec/%{shortname}
%{_usr}/libexec/%{shortname}-scanner
%{_usr}/libexec/%{shortname}-resized
%{_usr}/libexec/%{shortname}-cleanup

# Log files
%attr(0755,%{userd},%{groupd}) %dir %{_var}/log/%{shortname}
%attr(0644,%{userd},%{groupd}) %ghost %{_var}/log/%{shortname}/perfmon.log
%attr(0644,%{userd},%{groupd}) %ghost %{_var}/log/%{shortname}/server.log
%attr(0644,%{userd},%{groupd}) %ghost %{_var}/log/%{shortname}/scanner.log

# Systemd service file and preset file.
%attr(0644,root,root) %{_unitdir}/%{shortname}.service
%attr(0644,root,root) %{_presetdir}/50-%{shortname}.preset

# Configuration files and init script
%dir %{_sysconfdir}/%{shortname}
%attr(0755,%{userd},%{groupd}) %dir %{_var}/lib/%{shortname}/prefs
%attr(0644,%{userd},%{groupd}) %config(noreplace) %{_var}/lib/%{shortname}/prefs/server.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/log.conf
%attr(0755,%{userd},%{groupd}) %dir %{_var}/lib/%{shortname}/prefs/plugin
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/cli.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/datetime.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/infobrowser.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/itunes.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/musicmagic.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/podcast.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/radiotime.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/randomplay.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/rescan.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/rssnews.prefs
%attr(0644,%{userd},%{groupd}) %ghost %config(noreplace) %{_var}/lib/%{shortname}/prefs/plugin/state.prefs
%config(noreplace) %{_sysconfdir}/%{shortname}/server.conf
%attr(0644,%{userd},%{groupd}) %config(noreplace) %{_sysconfdir}/%{shortname}/convert.conf
%attr(0644,%{userd},%{groupd}) %config(noreplace) %{_sysconfdir}/%{shortname}/modules.conf
%attr(0644,%{userd},%{groupd}) %config(noreplace) %{_sysconfdir}/%{shortname}/types.conf
%attr(0644,root,root) %config(noreplace) %{_sysconfdir}/sysconfig/%{shortname}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{shortname}



%changelog
* Tue Jun 02 2026 Johan Saaw
- Removed support for Sys V Init. Red Hat and SUSE based distros
  moved to systemd many years ago. Also removed support for
  /etc/sysconfig/lyrionmusicserver
- Added systemd as pre-requisite with the %%systemd_requires macro.
- Added BuildRequires systemd-rpm-macros
- Added use of systemd_pre, systemd_preun, systemd_post and 
  systemd_postun_with_restart to initialise and handle the unit
  file and service correctly.
- Added a systemd preset file to enable lyrionmusicserver at
  installation time.
- Added logic to start lyrionmusicserver immediately during 
  install  if it is a first time installation. Upgrades will
  follow the packaging rules.
* Mon Oct 20 2025 Peter Oliver <rpm@mavit.org.uk>
- Drop support for Perl versions not currently seen in usage stats.
* Sat Feb 01 2025 Johan Saaw
- Removed selinux config support for mySQL/MariaDB databases as they are no
  longer officially supported for LMS
* Sat Aug 24 2024 Johan Saaw
- Simplified the logic around detecting whether a migration from 
  squeezeboxserver config to lyrionmusicserver configuration is needed.
  Removed dependecies on awk and grep in the pre and post scripts, replaced
  with in-line perl code.
  Added PreReqs for /bin/sh, getent, adduser and addgroup
  General clean-up in pre and post scripts. Using full paths
* Sun Jul 21 2024 Johan Saaw
-  As from version 9.0.0 the logitechmediaserver is called Lyrion Music Server.
   Re-branding everything to Lyrion Music server.
     - All components have been re-branded, everything that was called
       squeezeboxserver is now called lyrionmusicserver, the executables,
       all locations in the file systems.
     - The SYSV init script, the systemd unit have consequently also changed 
       name to lyrionmusicserver.
     - The daemons run under the user id and group lyrionmusicserver.
     - When a logitechmediaserver installation is upgraded to a 
       lyrionmusicserver installation, then the configuration of the 
       logitechmediaserver installation will be migrated to the 
       lyrionmusicserver if the config is in the default location and 
       /var/lib/lyrionmusicserver does not already exist. If these conditions
       are not met, then the lyrionmusicserver will have to be configured from
       scratch.

* Wed Apr  3 2024 Peter Oliver <rpm@mavit.org.uk>
- lyrionmusicserver obsoletes logitechmediaserver.

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
  when the lyrionmusicserver RPM is upgraded.
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
	- Simplify and rewrite %%pre and %%post scriptlets

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
- Added %%config(noreplace) to /etc/sysconfig/slimp3.
- Fixed two changes in the postinstall script that broke relocation.

* Thu Oct 24 2002   DV <datavortex@datavortex.net>
- changed account to a system account and shell to nologin.
- don't add user with default name if the admin changed it.

* Tue Oct 22 2002	Mike Arnold <mike@razorsedge.org>
- Fixed a problem with doing a package "upgrade" and losing the
  passwd entry for the slimp3 user in %%preun and %%postun.
- Made sure an existing /etc/slimp3.pref was not replaced by a newer package.
- Got rid of all the commented, tarball-removal stuff in %%pre.
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
  including a %%post hack to mod /etc/sysconfig/slimp3
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
- Kept %%postun from deleteing the %%config file as rpm takes care of this
- Changed software group to System Environment/Daemons
- Added a nice description
- Added %%clean

* Wed Aug 28 2002	Victor Brilon <victor@vail.net>
- First release
