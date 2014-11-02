# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


PREFIX = /usr
KBD_PREFIX = $(PREFIX)
ENV_PREFIX = $(PREFIX)
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
DEVDIR = /dev
TMPDIR = /tmp

PKGNAME = splashtool

WARN = -Wall -Wextra -pedantic -Wformat=2 -Winit-self -Wmissing-include-dirs   \
       -Wfloat-equal -Wshadow -Wmissing-prototypes -Wmissing-declarations      \
       -Wredundant-decls -Wnested-externs -Winline -Wno-variadic-macros        \
       -Wswitch-default -Wconversion -Wcast-align -Wstrict-overflow            \
       -Wdeclaration-after-statement -Wundef -Wcast-qual -Wbad-function-cast   \
       -Wwrite-strings -Waggregate-return -Wpacked -Wstrict-prototypes         \
       -Wold-style-definition  -Wdouble-promotion -Wtrampolines                \
       -Wsign-conversion -Wsync-nand -Wlogical-op                              \
       -Wvector-operation-performance -Wsuggest-attribute=const                \
       -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure                   \
       -Wsuggest-attribute=format -Wnormalized=nfkc -Wunsafe-loop-optimizations

FLAGS = -std=gnu99 -Ofast -lm $(WARN)



.PHONY: default
default: command info

.PHONY: all
all: command doc

.PHONY: command
command: bin/splashtool bin/assemble

bin/splashtool: src/splashtool
	@mkdir -p bin
	cp $< $@
	sed -i 's:/dev/:$(DEVDIR)/:g' $@
	sed -i 's:/usr/share/kbd/:$(KBD_PREFIX)$(DATA)/kbd/:g' $@
	sed -i 's:/tmp/:$(TMPDIR)/:g' $@

bin/assemble: obj/assemble.o
	@mkdir -p bin
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ $<

obj/assemble.o: src/assemble.c
	@mkdir -p obj
	$(CC) $(FLAGS) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

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
install-command: bin/assemble bin/splashtool
	install -dm755 "$(DESTDIR)$(BINDIR)"
	install -dm755 "$(DESTDIR)$(LIBEXECDIR)"
	install -m755 bin/assemble "$(DESTDIR)$(LIBEXECDIR)"/assemble
	install -m755 bin/splashtool "$(DESTDIR)$(LIBEXECDIR)"/splashtool
	ln -sfr "$(DESTDIR)$(LIBEXECDIR)"/splashtool "$(DESTDIR)$(BINDIR)"/splashtool

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
	-rm -- "$(DESTDIR)$(LIBEXECDIR)"/assemble
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

