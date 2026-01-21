.PHONY: all clean tests

CC = g++
CFLAGS = -std=c++17

all: clean
	flex scanner.lex
	bison -Wcounterexamples -d parser.y
	$(CC) $(CFLAGS) -g -o hw3 *.c *.cpp
tests:
	make
	./run_tests
clean:
	rm -f lex.yy.* parser.tab.* hw3
