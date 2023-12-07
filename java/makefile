

JSRC = Advent.java
JARFILE = advent.jar
ADVENT = java -jar advent.jar

run: $(JARFILE)
	$(ADVENT) 01a ../data/advent01.txt
	$(ADVENT) 01b ../data/advent01.txt

build: $(JARFILE)

$(JARFILE): $(JSRC)
	rm -rf tmp
	mkdir -p tmp
	javac -d tmp Advent.java
	jar cfe $@ Advent -C tmp .
	rm -rf tmp

clean:
	rm -rf $(JARFILE) tmp
