#
# vmc Makefile
#
# uses standard system C compiler
#

CFLAGS = -I. -m32
INSTALLIN = $(EMERALDROOT)/bin/$(EMERALDARCH)
OBJ = vmclex.o vmcpar.o semantic.o trace.o \
		iisc.o iset.o slist.o sisc.o ilist.o strings.o

.c.o:;	$(CC) -c $(CFLAGS) $*.c

CC = gcc -g

vmc:	$(OBJ)
	$(CC) $(CFLAGS) -o vmc $(OBJ) -ll

vmclex.c: vmclex.l
	lex vmclex.l
	mv lex.yy.c vmclex.c

vmclex.o:	vmcpar.h

vmcpar.h vmcpar.c:	vmcpar.y
	yacc -d vmcpar.y
	mv y.tab.h vmcpar.h
	mv y.tab.c vmcpar.c

vmc.o:	tokenNames.c vmcpar.h

tokenNames.c:	vmcpar.y
	csh MAKETN

clean:
	rm -f vmc $(OBJ) tokenNames.c vmcpar.h vmcpar.c vmclex.c core

mothball: clean
	rcsclean
	compress RCS/*

start:
	-uncompress RCS/*.Z
	co RCS

install: $(INSTALLIN)/vmc

$(INSTALLIN)/vmc : vmc
	if issymlink $@ ; then \
	  true ; \
	else \
	  rm -f $@ ; \
	  cp vmc $@ ; \
	  chmod g+w $@ ; \
	fi

lint:
	lint -bh *.c | egrep -v 'pointer alignment'

