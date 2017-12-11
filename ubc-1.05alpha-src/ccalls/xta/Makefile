#
# X library CCALL Makefile
#

SRCS = 
INCS = xta.h

default: all

all:

# begin --- Emerald interpreter targets ---

export: xsed ../xta.h

../xta.h: $(INCS)
	cat $(INCS) >$@

xsed: ../xsed.c xta.va
	rm -f xta.c
	../xsed < xta.va > xta.c

clean:

# end --- Emerald interpreter targets ---

# EOF
