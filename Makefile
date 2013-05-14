PREFIX = /usr
BIN = /bin
LIBEXEC = /libexec/splashtool


all: bin/Assemble.class

bin/Assemble.class: src/Assemble.java
	mkdir -p bin
	javac -cp src -s src -d bin src/Assemble.java

install: bin/Assemble.class
	mkdir -p "$(DESTDIR)$(BIN)"
	mkdir -p "$(DESTDIR)$(LIBEXEC)"
	install -m644 bin/Assemble.class "$(DESTDIR)$(LIBEXEC)"/Assemble.class
	install -m755 parse.py "$(DESTDIR)$(LIBEXEC)"/parse.py
	install -m755 trim.py "$(DESTDIR)$(LIBEXEC)"/trim.py
	install -m755 splashtool "$(DESTDIR)$(LIBEXEC)"/splashtool
	ln -s "$(LIBEXEC)"/splashtool "$(DESTDIR)$(BIN)"/splashtool

uninstall:
	rm "$(DESTDIR)$(BIN)"/splashtool
	rm "$(DESTDIR)$(LIBEXEC)"/Assemble.class
	rm "$(DESTDIR)$(LIBEXEC)"/parse.py
	rm "$(DESTDIR)$(LIBEXEC)"/trim.py
	rm "$(DESTDIR)$(LIBEXEC)"/splashtool
	-rmdir "$(DESTDIR)$(LIBEXEC)"

clean:
	-rm -r bin

