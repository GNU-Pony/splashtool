# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


PREFIX = /usr
BIN = /bin
LIBEXEC = /libexec/$(PKGNAME)
DATA = /share
BINDIR = $(PREFIX)$(BIN)
LIBEXECDIR = $(PREFIX)$(LIBEXEC)
DATADIR = $(PREFIX)$(DATA)
DOCDIR = $(DATADIR)/doc
INFODIR = $(DATADIR)/info
LICENSEDIR = $(DATADIR)/licenses
SYSCONFDIR = /etc
PROCDIR = /proc
DEVDIR = /dev
TMPDIR = /tmp

PKGNAME = splashtool



.PHONY: default
default: command info

.PHONY: all
all: command doc

.PHONY: command
command: bin/Assemble.class
bin/Assemble.class: src/Assemble.java
	mkdir -p bin
	javac -cp src -s src -d bin -encoding UTF-8 src/Assemble.java

.PHONY: doc
doc: info pdf ps dvi

.PHONY: info
info: splashtool.info
%.info: info/%.texinfo info/fdl.texinfo
	makeinfo $<

.PHONY: pdf
pdf: splashtool.pdf
%.pdf: info/%.texinfo info/fdl.texinfo
	@mkdir -p obj
	cd obj && yes X | texi2pdf ../$<
	mv obj/$@ $@

.PHONY: dvi
dvi: splashtool.dvi
%.dvi: info/%.texinfo info/fdl.texinfo
	@mkdir -p obj
	cd obj && yes X | $(TEXI2DVI) ../$<
	mv obj/$@ $@

.PHONY: ps
ps: splashtool.ps
%.ps: info/%.texinfo info/fdl.texinfo
	@mkdir -p obj
	cd obj && yes X | texi2pdf --ps ../$<
	mv obj/$@ $@


.PHONY: install
install: install-base install-info

.PHONY: install-all
install-all: install-base install-doc

.PHONY: install-base
install-base: install-command install-license

.PHONY: install-command
install-command: bin/Assemble.class
	install -dm755 "$(DESTDIR)$(BINDIR)"
	install -dm755 "$(DESTDIR)$(LIBEXECDIR)"
	install -m644 bin/Assemble.class "$(DESTDIR)$(LIBEXECDIR)"/Assemble.class
	install -m755 src/parse.py "$(DESTDIR)$(LIBEXECDIR)"/parse.py
	install -m755 src/trim.py "$(DESTDIR)$(LIBEXECDIR)"/trim.py
	install -m755 src/splashtool "$(DESTDIR)$(LIBEXECDIR)"/splashtool
	ln -sf "$(LIBEXECDIR)"/splashtool "$(DESTDIR)$(BINDIR)"/splashtool

.PHONY: install-license
install-license:
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 -- COPYING LICENSE "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"

.PHONY: install-doc
install-doc: install-info install-pdf install-ps install-dvi

.PHONY: install-info
install-info: splashtool.info
	install -dm755 -- "$(DESTDIR)$(INFODIR)"
	install -m644 -- $< "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"

.PHONY: install-pdf
install-pdf: splashtool.pdf
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 -- $< "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"

.PHONY: install-ps
install-ps: splashtool.ps
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 -- $< "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"

.PHONY: install-dvi
install-dvi: splashtool.dvi
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 -- $< "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"


uninstall:
	-rm -- "$(DESTDIR)$(BINDIR)"/splashtool
	-rm -- "$(DESTDIR)$(LIBEXECDIR)"/Assemble.class
	-rm -- "$(DESTDIR)$(LIBEXECDIR)"/parse.py
	-rm -- "$(DESTDIR)$(LIBEXECDIR)"/trim.py
	-rm -- "$(DESTDIR)$(LIBEXECDIR)"/splashtool
	-rmdir -- "$(DESTDIR)$(LIBEXECDIR)"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rmdir -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	-rm -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"


clean:
	-rm -r obj bin *.{info,pdf,dvi,ps}

