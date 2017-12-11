#
# Copyright (c) 1986 Robert R. Henry
#
# @(#)Makefile 1.2 1/9/87
#
DESTDIR=$(EMERALDROOT)/bin/$(EMERALDARCH)
CFLAGS= -DWORD32 -g
SRCS = Makefile dextern files yaccpar \
	y1.c y2.c y3.c y4.c \
	yaccdiffs yaccnews

all: emyacc
OBJS = y1.o y2.o y3.o y4.o

emyacc: $(OBJS)
	$(CC) -o emyacc $(OBJS)

$(OBJS): dextern files

install: $(DESTDIR)/emyacc

$(DESTDIR)/emyacc: emyacc
	if issymlink $@ ; then \
	  true ; \
	else \
	  rm -f $@ ; \
	  cp emyacc $@ ; \
	  chmod g+w $@ ; \
	fi

clean :
	-rm -f *.o emyacc core yacc.* ytab.*

srcs: $(SRCS)
$(SRCS):
	co $@
