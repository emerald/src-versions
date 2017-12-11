#
# X library CCALL Makefile
#

SRCS = 
INCS = xma.h

default: all

all:

# begin --- Emerald interpreter targets ---

export: ../xma.h

../xma.h: $(INCS)
	cat $(INCS) >$@

xsed: ../xsed.c xma.va
	rm -f xma.c
	../xsed < xma.va > xma.c

clean:

# end --- Emerald interpreter targets ---

# EOF
