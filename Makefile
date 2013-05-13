all: bin/Assemble.class

bin/Assemble.class: src/Assemble.java
	mkdir -p bin
	javac -cp src -s src -d bin src/Assemble.java

clean:
	-rm -r bin

