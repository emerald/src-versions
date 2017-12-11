#
# emx Makefile
#

#
# These are set in the macroMf file for the particular architecture
#
COPT   = $(OPTCOPT)
VMOPT  = $(OPTVMOPT)

CPFLAGS = -I. -DSINGLESTEP -DCOUNTBYTECODES -DSTDARG_WORKS \
	$(XCPFLAGS) $(X11FLA) $(LWPFLA)

# no dependencies, these must be kept up to date manually
LIB = $(XLIB) $(X11LIB) $(LWPLIB) $(EXTRALIB)

.c.o:
	rm -f $*.o ; $(CC) -c $(CFLAGS) $*.c

.c.s:
	rm -f $*.o ; $(CC) -S $(CFLAGS) $*.c

CFLAGS   = $(CPFLAGS) $(COPT)
VMFLAGS  = $(CPFLAGS) $(VMOPT)

INC = \
	array.h \
	assert.h \
	bufstr.h \
	builtins.h \
	call.h \
	concurr.h \
	config.h \
	creation.h \
	dist.h \
	extract.h \
	filestr.h \
	gaggle.h \
	gc.h \
	globals.h \
	iisc.h \
	iixsc.h \
	init.h \
	insert.h \
	io.h \
	iosc.h \
	iset.h \
	joveisc.h \
	jsys.h \
	jvisc.h \
	locate.h \
	misc.h \
	move.h \
	mqueue.h \
	oidtoobj.h \
	oisc.h \
	ooisc.h \
	otable.h \
	read.h \
	remote.h \
	rinvoke.h \
	squeue.h \
	storage.h \
	streams.h \
	system.h \
	timer.h \
	trace.h \
	types.h \
	vm.h \
	vm_i.h \
	vm_exp.h \
	write.h \
	$(X11INC) \
	$(LWPINC)

REALSRC = \
	array.c \
	bufstr.c \
	call.c \
	conform.c \
	creation.c \
	debug.c \
	dist.c \
	distgc.c \
	filestr.c \
	gaggle.c \
	gc.c \
	globals.c \
	iisc.c \
	iixsc.c \
	io.c \
	iosc.c \
	iset.c \
	joveisc.c \
	jsys.c \
	jvisc.c \
	locate.c \
	main.c \
	misc.c \
	move.c \
	mqueue.c \
	oidtoobj.c \
	oisc.c \
	ooisc.c \
	otable.c \
	read.c \
	remote.c \
	rinvoke.c \
	squeue.c \
	storage.c \
	streams.c \
	timer.c \
	trace.c \
	upcall.c \
	vm.c \
	write.c \
	$(X11SRC) \
	$(LWPSRC)

CCALLSOBJ = cctab.o $(CCALLS_OBJ)

CCALLSSRC = cctab.c $(CCALLS_SRC) 

SRC =	$(REALSRC) $(CCALLSSRC) vm.d

OBJ = \
	vm.o \
	array.o \
	bufstr.o \
	call.o \
	conform.o \
	creation.o \
	debug.o \
	dist.o \
	distgc.o \
	filestr.o \
	gaggle.o \
	gc.o \
	globals.o \
	iisc.o \
	iixsc.o \
	io.o \
	iosc.o \
	iset.o \
	joveisc.o \
	jsys.o \
	jvisc.o \
	locate.o \
	main.o \
	misc.o \
	move.o \
	mqueue.o \
	oidtoobj.o \
	oisc.o \
	ooisc.o \
	otable.o \
	read.o \
	remote.o \
	rinvoke.o \
	squeue.o \
	storage.o \
	streams.o \
	timer.o \
	trace.o \
	upcall.o \
	write.o \
	$(GCOBJ) \
	$(CCALLSOBJ) \
	$(X11OBJ) \
	$(LWPOBJ)

ASSRC = \
	vm.s \
	array.s \
	bufstr.s \
	call.s \
	conform.s \
	creation.s \
	debug.s \
	dist.s \
	distgc.s \
	filestr.s \
	gaggle.s \
	gc.s \
	globals.s \
	iisc.s \
	iixsc.s \
	io.s \
	iosc.s \
	iset.s \
	joveisc.s \
	jsys.s \
	jvisc.s \
	locate.s \
	main.s \
	misc.s \
	move.s \
	mqueue.s \
	oidtoobj.s \
	oisc.s \
	ooisc.s \
	otable.s \
	read.s \
	remote.s \
	rinvoke.s \
	squeue.s \
	storage.s \
	streams.s \
	timer.s \
	trace.s \
	upcall.s \
	write.s \
	$(GCASSRC) \
	$(CCALLSASSRC) \
	$(X11ASSRC) \
	$(LWPASSRC)

LIBDIR = lib/$(ARCH)

LOAD = $(LIBDIR)/userrt0.o $(OBJ) $(LIBDIR)/libxsim.a

all:	emx

install: emx $(EMLIBDIR)/bcdef $(EMLIBDIR)/jsdef

$(EMLIBDIR)/jsdef : jsys.h
	cp jsys.h $@
	chmod 664 $@

$(EMLIBDIR)/bcdef : vm.h
	cp vm.h $@
	chmod 664 $@

cctab.h cctab.c:	$(EMERALDROOT)/ccalls/*.h $(EMERALDROOT)/lib/$(EMERALDARCH)/macroMf
	gencctab $(CCALLS_OBJ)

tags:	$(SRC) $(INC)
	/usr/bin/ctags -tw $(SRC) $(INC)

cxref:	$(SRC) $(INC)
	cxref `make csrc inc` -xref -html $(CPFLAGS)
	cxref -index-all -html

vm.c:	vm.d
	if issymlink vm.c ; then \
	  mv -f ../src/vm.h ../src/vm.h.orig ; \
	  mv -f ../src/vm_i.h ../src/vm_i.h.orig ; \
	  rm -f ../src/vm.c ../src/vm.h ../src/vm_i.h ; \
	else \
	  mv -f vm.h vm.h.orig ; \
	  mv -f vm_i.h vm_i.h.orig ; \
	  rm -f vm.c vm.h vm_i.h ; \
	fi
	vmc vm.d
	if issymlink vm.c ; then \
	  if [ -r ../src/vm.h.orig ] && cmp -s ../src/vm.h ../src/vm.h.orig ; then mv ../src/vm.h.orig ../src/vm.h ; fi ; \
	  if [ -r ../src/vm_i.h.orig ] && cmp -s ../src/vm_i.h ../src/vm_i.h.orig ; then mv ../src/vm_i.h.orig ../src/vm_i.h ; fi ; \
	else \
	  if [ -r vm.h.orig ] && cmp -s vm.h vm.h.orig ; then mv vm.h.orig vm.h ; fi ; \
	  if [ -r vm_i.h.orig ] && cmp -s vm_i.h vm_i.h.orig ; then mv vm_i.h.orig vm_i.h ; fi ; \
	fi
	chmod -w vm.c vm.h vm_i.h

vm.o: vm.c types.h
	rm -f vm.o ; $(CC) $(VMFLAGS) -c vm.c

emx:	$(OBJ)
	@echo linking...
	@-rm -f emx.dead
	@-mv -f emx emx.dead
	$(CC) $(CFLAGS) $(OBJ) -o emx $(LIB) -lm
	@-rm -f emx.dead

emx.s:	$(ASSRC)

#
# Because test -h doesn't work on all machines, we use a
# machine dependent issymlink script
#
links:
	for x in $(REALSRC) vm.d $(INC) ; do \
	  if issymlink $$x ; then rm $$x ; fi ; \
	  ln -s ../src/$$x . ; \
	done

checkout:
	for x in $(REALSRC) vm.d $(INC) ; do \
	  if issymlink $$x ; then \
	    true; \
	  else if cmp -s ../src/$$x $$x ; then \
	    echo "$$x is a copy of the real thing." ; \
	  else \
	    echo "Something funny with $$x" ; \
	    ls -l $$x ; \
	  fi ; fi ; \
	done

mothball:	clean
	for x in $(REALSRC) vm.d $(INC) ; do \
	  if issymlink $$x ; then \
	    rm -f $$x ; \
	  else \
	    echo "Something funny with $$x" ; \
	    ls -l $$x ; \
	  fi ; \
	done
	rm Makefile

clean:
	rm -f emx $(OBJ) $(LWPOBJ)

sources src:
	@echo $(SRC) | sed -e 's/vm.c//'

csources csrc:
	@echo $(SRC) | sed -e 's/vm.d//'

objects obj:
	@echo $(OBJ)

includes inc:
	@echo $(INC)

# WARNING!  Hackish behaviour below.
# We require $SRC == $(REALSRC) $(CCALLSSRC) vm.d
# There appear to be dragons ^H^H^H line length limits on a Unix
# command, so we have to build dependencies with more than one
# command line.  Also, we can't do a make depend on vm.d,
# as it's not legal C, so need to exclude it specifically.
depend:	$(SRC)
	$(DEPEND) $(CFLAGS) $(REALSRC) >  Makefile.depend
	$(DEPEND) $(CFLAGS) $(CCALLSSRC)  >> Makefile.depend
