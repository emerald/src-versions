#
# Makefile for Emerald ccalls library
#
# invoke using emmake (i.e. not just make).  Emmake is located in
# ${EMERALDROOT}/bin or ${EMERALDRROT}/bin/${EMERALDARCH}.
#
#
# We list the subdirectories here explicitly, because in order to maintain
# compatibility with old already compiled code, we need to deal with them in
# the same order, so that they get the same identifiers.  
#
SUBDIRS = \
	emstream \
	string \
	rand \
	misk \
	regexp \
	xforms \
	xliba \
	xta \
	xma \
	bani \
	myristream

DOTHS = \
	emstream.h \
	string.h \
	rand.h \
	misk.h \
	regexp.h \
	xforms.h \
	xliba.h \
	xta.h \
	xma.h \
	bani.h \
	myristream.h

default: export

all: export

# to export the results for vm's consumption
install: export

# we don't name the actual export, to force this rule to be
# executed every time.
export:
	-/bin/rm -f xsed
	cc -o xsed xsed.c
	for i in $(SUBDIRS) ; do \
		(cd $$i ; echo "making $$i" ; $(EMMAKE) export) ; \
	done
	genccdef $(DOTHS)

# need to be able to rebuild everything cleanly; 
clean:
	rm -f $(DOTHS)
	for i in $(SUBDIRS)* ; do \
		(cd $$i ; echo "cleaning $$i" ; $(EMMAKE) clean) ; \
	done

doths:
	@echo $(DOTHS)


