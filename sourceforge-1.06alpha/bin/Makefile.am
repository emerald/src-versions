bin_SCRIPTS = gencctab ec emc emxx

CLEANFILES = gencctab

EXTRA_DIST = *

gencctab:	$(srcdir)/gencctab.sh
	rm -f gencctab
	echo "#! " $(SH) > gencctab
	cat $(srcdir)/gencctab.sh >> gencctab
	chmod ugo+x gencctab

ec:

emc:

emxx:
