SRCS = translator.tab.c lex.yy.c 
CC = gcc

# if we compile them all together, we should get out what we want!
all: $(SRCS)
	$(CC) $(SRCS) -lfl -o translator

# to regenerate the lexer, we call `flex` on it, which will
# create the flex translator.tab.c and translator.tab.h files
lexer.c: translator.l translator.tab.h
	flex translator.l

# to regenerate the parser, we call `bison` on it, which will
# create the translator.tab.c and translator.tab.h files
parser.c: translator.y translator.l 
	bison -d translator.y
