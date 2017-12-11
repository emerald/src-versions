bin_PROGRAMS = emx
emx_SOURCES = array.c \
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
	cctab.c 
#\
#	$(X11SRC) \
#	$(LWPSRC)
include_HEADERS = \
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
	cctab.h 
#\
#	$(X11INC) \
#	$(LWPINC)

LDADD = ../../ccalls/libccalls.a

EMERALDROOT=$(top_srcdir)
BUILT_SOURCES = cctab.c
CLEANFILES = cctab.c cctab.h
cctab.h: cctab.c
cctab.c: Makefile
	EMERALDROOT=$(top_srcdir) $(top_srcdir)/bin/gencctab.sh `cd $(top_srcdir)/ccalls;ls *.o`

