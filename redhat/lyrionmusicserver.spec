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
Packager:	Lyrion Community - please visit www.lyrion.org
Version:	%{_version}
Release:	%{rpm_release}
Summary:        Lyrion Music Server

Group:		System Environment/Daemons
License:	GPL and proprietary
URL:		https://www.lyrion.org
Source0:	%{src_basename}.tgz
Source1:	%{shortname}.config
Source2:	%{shortname}.init
Source3:	%{shortname}.logrotate
Source4:	%{shortname}.service
Source5:	README.systemd
Source6:        README.rebranding
BuildRoot:	%{_tmppath}/%{name}-%{version}-buildroot
Vendor:		Lyrion Community


Requires:	perl >= 5.10.0
Recommends:     perl(IO::Socket::SSL)

Provides:	%{src_basename} = %{version}-%{release}
Obsoletes:	logitechmediaserver
Obsoletes:	SliMP3
Obsoletes:	slimserver
Obsoletes:	squeezeboxserver
Obsoletes:	squeezecenter
AutoReqProv:	no

BuildArch:	noarch

%description
Lyrion Music Server powers the Squeezebox, Transporter and SLIMP3 network music
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
ln -s %{_var}/lib/%{shortname}/Plugins \
	$RPM_BUILD_ROOT%{_datadir}/%{shortname}/Plugins

# Install init, configuration and log files
install -Dp -m755 %SOURCE1 $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig/%{shortname}
install -Dp -m755 %SOURCE2 $RPM_BUILD_ROOT%{_datadir}/%{shortname}/%{shortname}.SYSV
install -Dp -m644 %SOURCE3 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/%{shortname}
install -Dp -m644 %SOURCE4 $RPM_BUILD_ROOT%{_datadir}/%{shortname}/%{shortname}.service
install -Dp -m644 %SOURCE5 $RPM_BUILD_ROOT%{_datadir}/%{shortname}/README.systemd
install -Dp -m644 %SOURCE6 $RPM_BUILD_ROOT%{_datadir}/%{shortname}/README.rebranding
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
ln -s %{_var}/lib/%{shortname}/prefs/server.prefs \
	$RPM_BUILD_ROOT%{_sysconfdir}/%{shortname}/server.conf


%clean
rm -rf $RPM_BUILD_ROOT


%pre
function checkConfigMigration () {

   test -f /tmp/squeezerpmdebug && set -x

   # We need to check if we are upgrading from the logitechmedia server
   # package to the lyrionmusic server package. If we are doing that
   # we must try to migrate the squeezeboxserver prefs files to
   # the new location of the lyrionmusicserver prefs files.
   # The prefs files must also be edited to replace the paths
   # pointing to the old squeezeboxserver prefs location
   # to the new locations of lyrionmusicserver.
   #

   # Start with checking if there is a Lyrion Muix server configuration file.
   # If there is, we will do no migration and just return immediately.
   if [ -f /var/lib/%{shortname}/prefs/server.prefs ]; then
      return 1
   fi

   # First see if currently the logitechmediaserver package is installed.
   currentPkg=`/usr/bin/rpm -q logitechmediaserver |/usr/bin/grep -v 'is not' | /usr/bin/awk -F "-" '{printf "%s %s\n",$1,$2}'` || :

   # Very early version of lyrionmusicserver also used the squeezeboxnaming
   # so we need to check for that too if the query for logitechmediaserver
   # did not return anything.
   if [ -z "$currentPkg" ]; then
      currentPkg=`/usr/bin/rpm -q lyrionmusicserver |/usr/bin/grep -v 'is not' | /usr/bin/awk -F "-" '{printf "%s %s\n",$1,$2}'` || :
   fi

   if [ -n "$currentPkg" ]; then

      # Either logitechmediaserver or lyrionmediaserver is installed
      name=`echo $currentPkg | awk '{print $1}'` || :
      version=`echo $currentPkg | awk '{print $2}'` || :
   
      # Touch a file to allow the post script to know that we are moving
      # from squeezeboxserver to lyrionmusicserver
      /usr/bin/touch /var/tmp/SqueezeToLyrion || :

      if [ "$name" = "logitechmediaserver" ]; then


         # The current installation is a logitechmediaserver, check if the config
         # is in the default location.
         if [[ -f /var/lib/squeezeboxserver/prefs/server.prefs ]]; then
            echo ""
            echo "#######################################################################"
            echo "INFORMATION"
            echo "Upgrading from a logitechmediaserver package to a lyrionmusicserver"
            echo "package!"
            echo "Will attempt to migrate the logitechmedia configuration in"
            echo "/var/lib/squeezeboxserver to the new lyrionmusicserver configuration in"
            echo "/var/lib/lyrionmusicserver."
            echo "#######################################################################"
            echo ""

            # Touch a file to allow the post script to know that the squeezeboxserver
            # config should be migrated.
            /usr/bin/touch /var/tmp/migrateSqueezeboxserverConfig || :
            
         else
            echo ""
            echo "#######################################################################"
            echo "** N O T E **"
            echo "Upgrading from a logitechmediaserver package to a lyrionmusicserver"
            echo " package!"
            echo "logitechmediaserver configuration is not in the default location!"
            echo "You will have to either reconfigure the Lyrion Music Server, or migrate"
            echo "your old configuration manually."
            echo "#######################################################################"
            echo ""
         fi


      elif [ "$name" = "lyrionmusicserver" ] && [ "$version" = "9.0.0" ]; then

         # The current installation is a lyrion music server version 9.0.0, early adopters
         # might still have the config in /var/lib/squeezeboxserver. This needs to be fixed.
         if [ -f /var/lib/squeezeboxserver/prefs/server.prefs ]; then
            echo ""
            echo "#######################################################################"
            echo "INFORMATION"
            echo "Upgrading from an early Lyrion Music Server beta package to a later"
            echo "Lyrion Music server package!"
            echo "Will attempt to migrate the configuration in /var/lib/squeezeboxserver"
            echo "to the new lyrionmusicserver configuration in"
            echo "/var/lib/lyrionmusicserver."
            echo "#######################################################################"
            echo ""

            # Touch a file to allow the post script to know that the squeezeboxserver
            # config should be migrated.
            /usr/bin/touch /var/tmp/migrateSqueezeboxserverConfig || :
            
         else
            echo ""
            echo "#######################################################################"
            echo "** N O T E **"
            echo "Upgrading from an early Lyrion Music Server beta package to a later"
            echo "Lyrion Music Server package!"
            echo "The configuration is not in the default location!"
            echo "You will have to either reconfigure the Lyrion Music Server, or migrate"
            echo "your old configuration manually."
            echo "#######################################################################"
            echo ""

         fi
      fi
   fi

   return 0
}

test -f /tmp/squeezerpmdebug && set -x
getent group %{groupd} >/dev/null || groupadd -r %{groupd}
getent passwd %{userd} >/dev/null || \
useradd -r -g %{groupd} -d %{_datadir}/%{shortname} -s /sbin/nologin \
    -c "Lyrion Music Server" %{userd}

# This function will set flags for the post script so that the post script will
# know if a migration from squeezeboxserver configuration to lyrionmusicserver
# configuration is necessary
checkConfigMigration

exit 0


%post
function parseSysconfigSqueezeboxserver {

        test -f /tmp/squeezerpmdebug && set -x

	# Some simple checks on the /etc/sysconfig/squeezeboxserver
	# No guarantees that these checks will catch all changes that may have
	# been made that might have an impact on the move to systemd
	. %{_sysconfdir}/sysconfig/%{shortname}
	if [ "$LYRION_USER" != "%{userd}" ] ; then
                echo ""
                echo "#######################################################################"
		echo "You seem to have changed the user id used to run %{shortname}."
		echo "Please read %{_datadir}/%{shortname}/README.systemd to find out"
		echo "how transfer this change to the new systemd set-up."
                echo "#######################################################################"
                echo ""
	fi

	# Check if any additions to the LYRION_ARGS variable have been made.
	# Do that by filter out the ones we know should be there.
	extra=`echo $LYRION_ARGS |tr " " "\n"|grep -v -E "(--daemon|--prefsdir|--logdir|--cachedir|--charset)"` || :
	if [ -n "$extra" ] ; then
                echo ""
                echo "#######################################################################"
		echo "You seem to have changed the LYRION_ARGS variable in %{_sysconfdir}/sysconfig/%{shortname}."
		echo "Please read %{_datadir}/%{shortname}/README.systemd to find out"
                echo "how transfer this change to the new systemd set-up."
                echo "#######################################################################"
                echo ""
	fi
}

function setSelinux {

        test -f /tmp/squeezerpmdebug && set -x

	MYSQLPORT=9092
	CACHEDIR=%{_var}/lib/%{shortname}/cache

	# Add SELinux contexts
	# We need this irrespective of whether it is a systemd or SYSV server.
	if [ -x /usr/sbin/selinuxenabled ] ; then
		if /usr/sbin/selinuxenabled ; then
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage port -a -t mysqld_port_t -p tcp ${MYSQLPORT} > /dev/null 2>&1
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -a -t mysqld_db_t "${CACHEDIR}(/.*)?" > /dev/null 2>&1
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -a -t mysqld_var_run_t "${CACHEDIR}/%{shortname}-mysql.sock" > /dev/null 2>&1
			/sbin/restorecon -R ${CACHEDIR} > /dev/null 2>&1
		fi
	fi
}

function setSYSV {

        test -f /tmp/squeezerpmdebug && set -x

	# This is a SYSV server. Copy SYSV script to the correct place.
	cp -p %{_datadir}/%{shortname}/%{shortname}.SYSV %{_sysconfdir}/init.d/%{shortname} >/dev/null 2>&1 || :

	#Koozali SME Server pre version 10 uses SYSV init and uses runlevel 7
        # I have no idea if the release file is still called /etc/e-smit-release.
	if [ -f /etc/e-smith-release -a -d /etc/rc7.d ] ; then
		ln -sf %{_sysconfdir}/init.d/%{shortname} /etc/rc7.d/S80%{shortname} >/dev/null 2>&1 || :
		db configuration set %{shortname} service status enabled >/dev/null 2>&1 || :
	fi

        # Check if we are moving from squeezeboxserver to lyrionmusicserver
        # if we are, then we must explicitly stop the squeezeboxserver, 
        # otherwise the start of the lyrionmusicserver will fail.
        if [ -f /var/tmp/SqueezeToLyrion ]; then
           /sbin/service squeezeboxserver stop || :
           /usr/bin/rm -f /var/tmp/SqueezeToLyrion || :
        fi

	/sbin/chkconfig --add %{shortname} >/dev/null 2>&1 || :
	/sbin/service %{shortname} restart >/dev/null 2>&1 || :
}

function setSystemd {

        test -f /tmp/squeezerpmdebug && set -x
	# The SME server (now a days Koozali SME) started using systemd with
        # version 10 (based on CentOS 7). Next version is based on Rocky Linux.
        # So we don't need any special handling for Koozali SME here.

	if [ -n "$migrate" ] ; then
		# If we currently are running through a SYSV script. First stop
 		/sbin/service %{shortname} stop >/dev/null 2>&1 || :
		/sbin/chkconfig --del %{shortname} >/dev/null 2>&1 || :
		# We should not remove the old SYSV init file. The RPM
		# package will take care of this when we do an upgrade.
	fi

        # Check if we are moving from squeezeboxserver to lyrionmusicserver
        # if we are, then we must explicitly stop the squeezeboxserver, 
        # otherwise the start of the lyrionmusicserver will fail.
        if [ -f /var/tmp/SqueezeToLyrion ]; then
           /usr/bin/systemctl stop squeezeboxserver.service >/dev/null 2>&1 || :
           /usr/bin/rm -f /var/tmp/SqueezeToLyrion || :
        fi

	cp -p %{_datadir}/%{shortname}/%{shortname}.service /usr/lib/systemd/system/%{shortname}.service || :
	/usr/bin/systemctl daemon-reload >/dev/null 2>&1 || :
        /usr/bin/systemctl enable  %{shortname}.service >/dev/null 2>&1 || :
        /usr/bin/systemctl restart %{shortname}.service >/dev/null 2>&1 || :
}

function migrateSqueezeboxServerConfig {

   test -f /tmp/squeezerpmdebug && set -x

   if ! /usr/bin/cp -pr /var/lib/%{shortname} /var/lib/%{shortname}.bck >/dev/null 2>&1; then

      # Make a safety copy of the empty lyrion config.
      echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
      # Remove the safety copy (or whatever was created).
      rm -fr /var/lib/%{shortname}.bck >/dev/null 2>&1 || :
      return 1

   fi

   if ! /usr/bin/cp -pr /var/lib/squeezeboxserver/* /var/lib/%{shortname} >/dev/null 2>&1; then

      echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
      # Restore the safety copy
      rm -f -r /var/lib/%{shortname} >/dev/null 2>&1 || :
      mv /var/lib/%{shortname}.bck /var/lib/%{shortname} >/dev/null 2>&1 || :
      return 1

   else

      if ! /usr/bin/find /var/lib/%{shortname} -type f -name "*.prefs" -exec sed -i 's#/squeezeboxserver#/%{shortname}#g' {} \; >/dev/null 2>&1; then
         echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
         # Restore the safety copy
         rm -fr /var/lib/%{shortname} >/dev/null 2>&1 || :
         mv /var/lib/%{shortname}.bck /var/lib/%{shortname} || :
         return 1
      fi


      if ! /usr/bin/chown -R %{userd}:%{groupd} /var/lib/%{shortname} >/dev/null 2>&1; then
         echo "WARNING, failed migrating old configuration. You will need to migrate it manually or configure Lyrion Music Server from scratch."
         # Restore the safety copy
         rm -fr /var/lib/%{shortname} >/dev/null 2>&1 || :
         mv /var/lib/%{shortname}.bck /var/lib/%{shortname} || :
         return 1
      fi

   fi

   # Remove safety backup 
   rm -fr /var/lib/%{shortname}.bck >/dev/null 2>&1 || :

   # Remove migratiopn flag file
   /usr/bin/rm -f /var/tmp/migrateSqueezeboxserverConfig

   # Print message about rebranding.
   echo ""
   echo "#######################################################################"
   echo "NOTE"
   echo "From version 9.0.0 the Logitech Media Server has been rebranded Lyrion Music Server."
   echo "All Components of the software have been re-branded from squeezeboxserver to"
   echo "lyrionmusicserver. To stop and start the software use:"
   echo "systemd start lyrionmusicserver (on systemd systems)"
   echo "/sbin/service lyrionmusicserver start (on SYSV Init systems)."
   echo "and analogous for stop, status etc."
   echo ""
   echo "For more information, read %{_datadir}/%{shortname}/README.rebranding."
   echo "#######################################################################"
   echo ""

}

test -f /tmp/squeezerpmdebug && set -x

# Source /etc/os-release to find out what kind of system we are on.
# We will use ID_LIKE from this file
. /etc/os-release || :

# If the SYSV init script exists and the server uses systemd
# then migrate to systemd unit file.
if [ -e /etc/init.d/%{shortname} -a -x /usr/bin/systemctl ] ; then
	migrate=true
fi

# If CentOS/RedHat/Fedora, handle selinux
if [ -f /etc/redhat-release -o -n "$(echo $ID_LIKE |/usr/bin/grep -i -E '(centos|redhat|rhel|fedora)')" ] ; then
        setSelinux
fi

# Check if we need to migrate a squeezeboxserver config to lyrion music server

if [ -f /var/tmp/migrateSqueezeboxserverConfig ]; then

   migrateSqueezeboxServerConfig

fi

if [ ! -x /usr/bin/systemctl ] ; then
	setSYSV
else
	setSystemd
fi

PORT=`awk '/^httpport/ {print $2}' %{_var}/lib/%{shortname}/prefs/server.prefs`
[ -z "$PORT" ] && PORT=9000
HOSTNAME=`uname -n`

if [ -n "$migrate" ] ; then
	echo "Lyrion Music Server was migrated from old style SYSV to systemd start-up."
	parseSysconfigSqueezeboxserver || :
fi

echo "Point your web browser to http://$HOSTNAME:$PORT/ to configure Lyrion Music Server."

%preun
test -f /tmp/squeezerpmdebug && set -x
function unsetSelinux {

	# Remove SELinux contexts
	MYSQLPORT=9092
	CACHEDIR=%{_var}/lib/%{shortname}/cache
	if [ -x /usr/sbin/selinuxenabled ] ; then
		if /usr/sbin/selinuxenabled; then
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage port -d -t mysqld_port_t -p tcp ${MYSQLPORT}
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -d -t mysqld_db_t "${CACHEDIR}(/.*)?"
			[ -x /usr/sbin/semanage ] && /usr/sbin/semanage fcontext -d -t mysqld_var_run_t "${CACHEDIR}/%{shortname}-mysql.sock"
			/sbin/restorecon -R ${CACHEDIR}
		fi
	fi

}

function unsetSYSV {

	/sbin/service %{shortname} stop >/dev/null 2>&1 || :
	if [ -f /etc/e-smith-release -a -d /etc/rc7.d ] ; then
		#SME Server uses runlevel 7
		db configuration set %{shortname} service status disabled >/dev/null 2>&1 || :
		rm /etc/rc7.d/S80%{shortname} || :
	fi
       	/sbin/chkconfig --del %{shortname} >/dev/null 2>&1 || :
	# Remove the SYSV file we copied in the post script.
	rm -f /etc/init.d/%{shortname} || :

}

function unsetSystemd {

	# systemd
        /usr/bin/systemctl unmask %{shortname}.service >/dev/null 2>&1 || :
	/usr/bin/systemctl disable %{shortname}.service >/dev/null 2>&1 || :
	/usr/bin/systemctl stop %{shortname}.service >/dev/null 2>&1 || :
	# Remove the unit file we copied in the post script.
	rm -f /usr/lib/systemd/system/%{shortname}.service || :
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
