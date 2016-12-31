# Uncomment the following line to debug with Electric Fence.
#EFENCE = -lefence

# Uncomment the following to allow profiling.
#PROFILE = -pg

include makeinfo

all: ticker
ticker: ticker.c
	gcc ticker.c -o ticker $(CFLAGS) $(LIBS)

demo: ticker
	PATH=.:$$PATH ./ticker "This is a test..."

distclean: clean
	find . -name '\#*\#' -o -name '*.bak' -o -name '.??*' -o \
		-name '*~' -o -name '.gdb_history' -exec rm {} \;
	rm -f gmon.out config.h config.cache config.log config.status \
		makeinfo slang.h

clean:
	rm -f ticker

install:
	$(INSTALL) -d $(DESTDIR)/$(MANDIR)/man1 $(DESTDIR)/$(BINDIR)
	$(INSTALL_PROGRAM) ticker $(DESTDIR)/$(BINDIR)
	$(INSTALL) -m 0644 ticker.1 $(DESTDIR)/$(MANDIR)/man1

configure: configure.ac
	autoconf

config.status: configure
	./configure

makeinfo: autoconf/makeinfo.in config.status
	./config.status
