PREFIX = /usr
BIN = /bin
PKGNAME = splashtool
LIBEXEC = /libexec/$(PKGNAME)
DATA = /share
LICENSES = $(PREFIX)$(DATA)/licenses


all: classes doc


doc: info

info: splashtool.info.gz

%.info.gz: info/%.texinfo
	makeinfo "$<"
	gzip -9 -f "$*.info"


classes: bin/Assemble.class

bin/Assemble.class: src/Assemble.java
	mkdir -p bin
	javac -cp src -s src -d bin src/Assemble.java


install: bin/Assemble.class splashtool.info.gz
	install -dm755 "$(DESTDIR)$(PREFIX)$(BIN)"
	install -dm755 "$(DESTDIR)$(PREFIX)$(LIBEXEC)"
	install -dm755 "$(DESTDIR)$(PREFIX)$(DATA)/info"
	install -dm755 '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	install -m644 bin/Assemble.class "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/Assemble.class
	install -m755 src/parse.py "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/parse.py
	install -m755 src/trim.py "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/trim.py
	install -m755 src/splashtool "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/splashtool
	ln -s "$(PREFIX)$(LIBEXEC)"/splashtool "$(DESTDIR)$(PREFIX)$(BIN)"/splashtool
	install -m644 COPYING LICENSE '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	install -m644 splashtool.info.gz "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"

uninstall:
	rm -- "$(DESTDIR)$(PREFIX)$(BIN)"/splashtool
	rm -- "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/Assemble.class
	rm -- "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/parse.py
	rm -- "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/trim.py
	rm -- "$(DESTDIR)$(PREFIX)$(LIBEXEC)"/splashtool
	-rmdir -- "$(DESTDIR)$(PREFIX)$(LIBEXEC)"
	rm -- '$(DESTDIR)$(LICENSES)/$(PKGNAME)/COPYING'
	rm -- '$(DESTDIR)$(LICENSES)/$(PKGNAME)/LICENSE'
	rmdir -- '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	rm -- '$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz'


clean:
	-rm -r bin {*,info/*}.{aux,cp,fn,info,ky,log,pdf,ps,dvi,pg,toc,tp,vr}

