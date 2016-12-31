Summary: configurable text scroller
Name: ticker
Version: 1.10
Release: 1
Source: ticker-%{version}.tar.gz
Copyright: GPL
URL: http://kitenet.net/~joey/code/ticker
Group: Applications/Networking
BuildRoot: %{_builddir}/%{name}-root

%description
Ticker is a simple program to scroll text across a line of the display, in
a manner similar to a stock ticker. In fact, since ticker supports
communicating with a program that changes the text periodically, it could
be used to implement a stock ticker.

%prep
%setup
./configure --prefix=$RPM_BUILD_ROOT/usr --mandir=$RPM_BUILD_ROOT/usr/share/man

%build
CFLAGS="$RPM_OPT_FLAGS" make

%install
make install DESTDIR=$RPM_BUILD_ROOT

%files
%doc README CHANGES COPYING
/usr/bin/ticker
/usr/share/man/man1/ticker.1*
