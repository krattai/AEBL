# norootforbuild

Name:           xtreemfs
Version:        _VERSION_
Release:        %mkrel
License:        BSD-3-Clause
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Group:          System/Filesystems
URL:            http://www.XtreemFS.org
Summary:        XtreemFS base package
Source0:        XtreemFS-%{version}.tar.gz

#requires for any distribution
%if 0%{?sles_version} == 10 || 0%{?fedora_version} >= 20
# no need for ant-nodeps for SLE 10
%else
BuildRequires:  ant-nodeps >= 1.6.5
%endif
BuildRequires:  ant >= 1.6.5 ant-apache-regexp >= 1.6.5 java-devel >= 1.6.0
# Client dependencies.
BuildRequires:  gcc-c++ >= 4.1 fuse >= 2.6 fuse-devel >= 2.6 openssl-devel >= 0.9.8 cmake >= 2.6 boost-devel >= 1.35 libattr-devel >= 2

# openSUSE >=10.2
%if 0%{?suse_version} >= 1020
PreReq:         /usr/sbin/groupadd /usr/sbin/useradd /bin/mkdir /usr/bin/grep /bin/chmod /bin/chown /bin/chgrp /usr/bin/stat
#BuildRequires:  libopenssl-devel >= 0.8
BuildRequires:  pwdutils >= 3
%endif

# Mandriva >=2008
%if 0%{?mandriva_version} >= 2007
Requires(pre):  /usr/sbin/groupadd /usr/sbin/useradd /bin/mkdir /bin/grep /bin/chmod /bin/chown /bin/chgrp /bin/stat
#BuildRequires:  libopenssl-devel >= 0.8 libboost-devel >= 1.42
%endif

# Fedora >=7 with Extras
%if 0%{?fedora_version} >= 7
Requires(pre):  /usr/sbin/groupadd /usr/sbin/useradd /bin/mkdir /bin/grep /bin/chmod /bin/chown /bin/chgrp /usr/bin/stat
#BuildRequires:  openssl-devel >= 0.8
BuildRequires:  kernel redhat-rpm-config
%endif

%description
XtreemFS is a distributed and replicated file system for the internet. For more details, visit www.xtreemfs.org.

%package client
Summary:        XtreemFS client
Group:          System/Filesystems
#Requires:       %{name} == %{version}-%{release}
Requires:       fuse >= 2.6
Requires:       attr >= 2
Provides:       XtreemFS-client = %{version}
Obsoletes:      XtreemFS-client < %{version}

%description client
XtreemFS is a distributed and replicated file system for the internet. For more details, visit www.xtreemfs.org.

This package contains the XtreemFS client module.

%package backend
Summary:        XtreemFS backend modules and libraries
Group:          System/Filesystems
#Requires:       %{name} == %{version}-%{release}
Requires:       jre >= 1.6.0

%description backend
XtreemFS is a distributed and replicated file system for the internet. For more details, visit www.xtreemfs.org.

This package contains the backend modules and libraries shared between the server and tools sub-packages.

%package server
Summary:        XtreemFS server components (DIR, MRC, OSD)
Group:          System/Filesystems
Requires:       %{name}-backend == %{version}-%{release}
Requires:       grep
Requires:       jre >= 1.6.0
Provides:       XtreemFS-server = %{version}
Obsoletes:      XtreemFS-server < %{version}
Requires(post): util-linux

%description server
XtreemFS is a distributed and replicated file system for the internet. For more details, visit www.xtreemfs.org.

This package contains the XtreemFS server components (DIR, MRC, OSD).

%package tools
Summary:        XtreemFS administration tools
Group:          System/Filesystems
Requires:       %{name}-backend == %{version}-%{release}
Requires:       attr >= 2
Requires:       jre >= 1.6.0
Provides:       XtreemFS-tools = %{version}
Obsoletes:      XtreemFS-tools < %{version}

%description tools
XtreemFS is a distributed and replicated file system for the internet. For more details, visit www.xtreemfs.org.

This package contains XtreemFS administration tools.

%prep
%setup -q -n XtreemFS-%{version}


%build
export ANT_OPTS=-D"file.encoding=UTF-8"
export CFLAGS="$RPM_OPT_FLAGS -fno-strict-aliasing"
export CXXFLAGS=$CFLAGS

%if 0%{?mandriva_version} == 2008 || 0%{?centos_version} >= 501 || 0%{?rhel_version} >= 501 || 0%{?suse_version} == 1030
export CCFLAGS="$CCFLAGS -fPIC"
%endif

make %{?jobs:-j%jobs}

%install
export NO_BRP_CHECK_BYTECODE_VERSION=true

make install DESTDIR=$RPM_BUILD_ROOT
ln -sf /usr/bin/mount.xtreemfs ${RPM_BUILD_ROOT}/sbin/mount.xtreemfs
ln -sf /usr/bin/umount.xtreemfs ${RPM_BUILD_ROOT}/sbin/umount.xtreemfs

# add /etc/xos/xtreemfs/truststore/certs/ folder used for storing certificates
mkdir -p $RPM_BUILD_ROOT/etc/xos/xtreemfs/truststore/certs/

# Create log directory.
mkdir -p $RPM_BUILD_ROOT/var/log/xtreemfs

# remove copyright notes (let rpm handle that)
rm $RPM_BUILD_ROOT/usr/share/doc/xtreemfs-client/LICENSE
rmdir $RPM_BUILD_ROOT/usr/share/doc/xtreemfs-client
rm $RPM_BUILD_ROOT/usr/share/doc/xtreemfs-server/LICENSE
rmdir $RPM_BUILD_ROOT/usr/share/doc/xtreemfs-server
rm $RPM_BUILD_ROOT/usr/share/doc/xtreemfs-tools/LICENSE
rmdir $RPM_BUILD_ROOT/usr/share/doc/xtreemfs-tools

rm $RPM_BUILD_ROOT/etc/xos/xtreemfs/postinstall_setup.sh

%pre server
/usr/sbin/groupadd xtreemfs 2>/dev/null || :
/usr/sbin/useradd -r --home /var/lib/xtreemfs -g xtreemfs xtreemfs 2>/dev/null || :
/usr/sbin/usermod -g xtreemfs xtreemfs 2>/dev/null || :


%post server
#$XTREEMFS_CONFIG_DIR/postinstall_setup.sh
_POSTINSTALL_

%if 0%{?suse_version}
%fillup_and_insserv -f xtreemfs-dir xtreemfs-mrc xtreemfs-osd
%endif
%if 0%{?fedora_version}
/sbin/chkconfig --add xtreemfs-dir
/sbin/chkconfig --add xtreemfs-mrc
/sbin/chkconfig --add xtreemfs-osd
%endif
%if 0%{?mandriva_version}
%_post_service xtreemfs-dir xtreemfs-mrc xtreemfs-osd
%endif
# TODO(mberlin): Discuss with Nico if an else is required here.

%preun server
%if 0%{?suse_version}
%stop_on_removal xtreemfs-dir xtreemfs-mrc xtreemfs-osd
%endif
%if 0%{?fedora_version}
# 0 packages after uninstall -> pkg is about to be removed
  if [ "$1" = "0" ] ; then
    /sbin/service xtreemfs-dir stop >/dev/null 2>&1
    /sbin/service xtreemfs-mrc stop >/dev/null 2>&1
    /sbin/service xtreemfs-osd stop >/dev/null 2>&1
    /sbin/chkconfig --del xtreemfs-dir
    /sbin/chkconfig --del xtreemfs-mrc
    /sbin/chkconfig --del xtreemfs-osd
  fi
%endif
%if 0%{?mandriva_version}
%_preun_service xtreemfs-dir xtreemfs-mrc xtreemfs-osd
%endif

%postun server
%if 0%{?suse_version}
%restart_on_update xtreemfs-dir xtreemfs-mrc xtreemfs-osd
%insserv_cleanup
%endif
%if 0%{?fedora_version}
# >=1 packages after uninstall -> pkg was updated -> restart
if [ "$1" -ge "1" ] ; then
  /sbin/service xtreemfs-dir try-restart >/dev/null 2>&1 || :
  /sbin/service xtreemfs-mrc try-restart >/dev/null 2>&1 || :
  /sbin/service xtreemfs-osd try-restart >/dev/null 2>&1 || :
fi
%endif
%if 0%{?mandriva_version}
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files client
%defattr(-,root,root,-)
/usr/bin/*.xtreemfs
/usr/bin/xtfsutil
/sbin/*.xtreemfs
/usr/share/man/man1/*.xtreemfs*
/usr/share/man/man1/xtfsutil*
%doc LICENSE

%files backend
%defattr(-,root,root,-)
/usr/share/java/XtreemFS.jar
/usr/share/java/Foundation.jar
/usr/share/java/protobuf-java-2.5.0.jar
/usr/share/java/Flease.jar
/usr/share/java/BabuDB.jar
/usr/share/java/BabuDB_replication_plugin.jar
/usr/share/java/jdmkrt.jar
/usr/share/java/jdmktk.jar
/usr/share/java/commons-codec-1.3.jar
%doc LICENSE

%files server
%defattr(-,root,xtreemfs,-)
%attr(-,root,root) /etc/init.d/xtreemfs-*
%dir %attr(-,root,root) /usr/share/xtreemfs
%attr(-,root,root) /usr/share/xtreemfs/xtreemfs-osd-farm
%dir /etc/xos/
%dir %attr(0750,root,xtreemfs) /etc/xos/xtreemfs/
%dir %attr(0750,root,xtreemfs) /etc/xos/xtreemfs/truststore/
%dir %attr(0750,root,xtreemfs) /etc/xos/xtreemfs/truststore/certs/
%config(noreplace) %attr(0640,root,xtreemfs) /etc/xos/xtreemfs/*.properties
/etc/xos/xtreemfs/generate_uuid
# /etc/xos/xtreemfs/postinstall_setup.sh
%dir /etc/xos/xtreemfs/server-repl-plugin/
%config(noreplace) %attr(0640,root,xtreemfs) /etc/xos/xtreemfs/server-repl-plugin/dir.properties
%config(noreplace) %attr(0640,root,xtreemfs) /etc/xos/xtreemfs/server-repl-plugin/mrc.properties
%dir %attr(0750,xtreemfs,xtreemfs) /var/log/xtreemfs
%doc LICENSE

%files tools
%defattr(-,root,root,-)
%config(noreplace) /etc/xos/xtreemfs/default_dir
/usr/bin/xtfs_*
/usr/share/man/man1/xtfs_*
%doc LICENSE

%changelog
