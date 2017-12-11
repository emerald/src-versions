noinst_LIBRARIES = libccalls.a

libccalls_a_SOURCES = emstream/emstream.c \
	emstream/emstream.h \
	string/string.h \
	string/string.c \
	rand/rand.h \
	rand/rand.c \
	misk/misk.c  \
	misk/misk.h 
#	regexp/regexp.c \
#	xforms/xforms.c \
#	xforms/xforms.h \
#	xliba/xliba.c \
#	xliba/xliba.h \
#	xta/xta.c \
#	xta/xta.h \
#	xta/xta.va \
#	xma/xma.c \
#	xma/xma.h \
#	bani/bani.c \
#	bani/bani.h \
#	myristream/myristream.c
#	myristream/myristream.h

#libccalls_a_DEPENDENCIES = export

BUILT_SOURCES = emstream.h string.h rand.h misk.h
CLEANFILES = emstream.h string.h rand.h misk.h

emstream.h: 
	cp emstream/emstream.h .

string.h: 
	cp string/string.h .

rand.h: 
	cp rand/rand.h .

misk.h:
	cp misk/misk.h .

	
INCLUDES = -I../vm/src #-I./string -I./emstream -I./rand -I./misk

EXTRA_DIST = bani misc myristream notreadable regexp xforms xliba xma xta

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

doths:
	@echo $(DOTHS)

