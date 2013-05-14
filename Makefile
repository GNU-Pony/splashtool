PREFIX = /usr
BIN = /bin
LIBEXEC = /libexec/splashtool
PKGNAME = splashtool
DATA = /share
LICENSES = $(PREFIX)$(DATA)/licenses


all: classes doc


doc: info

info: splashtool.info.gz

%.info.gz: info/%.texinfo.install
	makeinfo "$<"
	gzip -9 -f "$*.info"


classes: bin/Assemble.class

bin/Assemble.class: src/Assemble.java
	mkdir -p bin
	javac -cp src -s src -d bin src/Assemble.java


install: bin/Assemble.class splashtool.info.gz
	install -dm755 "$(DESTDIR)$(BIN)"
	install -dm755 "$(DESTDIR)$(LIBEXEC)"
	install -dm755 "$(DESTDIR)$(DATA)/info"
	install -dm755 '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	install -m644 bin/Assemble.class "$(DESTDIR)$(LIBEXEC)"/Assemble.class
	install -m755 parse.py "$(DESTDIR)$(LIBEXEC)"/parse.py
	install -m755 trim.py "$(DESTDIR)$(LIBEXEC)"/trim.py
	install -m755 splashtool "$(DESTDIR)$(LIBEXEC)"/splashtool
	ln -s "$(LIBEXEC)"/splashtool "$(DESTDIR)$(BIN)"/splashtool
	install -m644 COPYING LICENSE '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	install -m644 splashtool.info.gz "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"

uninstall:
	rm -- "$(DESTDIR)$(BIN)"/splashtool
	rm -- "$(DESTDIR)$(LIBEXEC)"/Assemble.class
	rm -- "$(DESTDIR)$(LIBEXEC)"/parse.py
	rm -- "$(DESTDIR)$(LIBEXEC)"/trim.py
	rm -- "$(DESTDIR)$(LIBEXEC)"/splashtool
	-rmdir -- "$(DESTDIR)$(LIBEXEC)"
	rm -- '$(DESTDIR)$(LICENSES)/$(PKGNAME)/COPYING'
	rm -- '$(DESTDIR)$(LICENSES)/$(PKGNAME)/LICENSE'
	rmdir -- '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	rm -- '$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz'


clean:
	-rm -r bin {*,info/*}.{aux,cp,fn,info,ky,log,pdf,ps,dvi,pg,toc,tp,vr}

