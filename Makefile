SRCS = translator.tab.c lex.yy.c 
CC = gcc -O3

# if we compile them all together, we should get out what we want!
all: $(SRCS)
	$(CC) $(SRCS) -lfl -o translator

flex lex.yy.c: translator.l translator.tab.h translator.tab.c
	flex translator.l

translator.tab.c translator.tab.h: translator.y translator.l 
	bison -d translator.y

clean:
	rm -f translator translator.tab.c translator.tab.h lex.yy.c 