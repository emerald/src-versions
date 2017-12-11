#
# ExecTests Makefile
#

SOURCES = taaaa.m ta.m ttype.m tarray.m tbchunk.m tboolean.m tchar.m \
	  tclass.m thairy.m \
	  tiostr.m tinstr.m tinteger.m tnil.m tnode.m toutstr.m \
	  treal.m trecord.m tstack.m tstring.m ttime.m tv.m tvector.m

TARGETS = $(SOURCES:.m=.x)

EMX = emx
EMC = emc

compile:	$(SOURCES)
	cp /dev/null name
	rm -f name.idb name.ats name.oid
	rm -f xxinput
	echo >> xxinput load name
	echo >> xxinput unset docompilation
	echo >> xxinput runtest.m
	echo >> xxinput set docompilation
	for x in $? ; do \
	    echo $$x >> xxinput ;\
	done
	echo source xxinput | $(EMC)
	rm -f xxinput
	touch compile

fasttest:
	@rm -f tmp
	$(EMX) runtest.x `echo $(TARGETS) | sed -e 's/tinstr.x//' -e s/toutstr.x//'`

test dotest:
	@rm -f tmp
	@-for name in ${TARGETS} ; do \
	    bn=`basename $$name .x` ; \
	    if  [ -r $$bn.in ] ; then \
		if [ -r $$bn.out ] ; then \
		    rm -f $$bn.ou~; \
		    ${EMX}  runtest.x $$bn.x < $$bn.in > $$bn.ou~ ; \
		    if cmp -s $$bn.out $$bn.ou~ ; then \
			echo "Test \"$$bn\" starting ... completed successfully." ; \
			rm $$bn.ou~ ; \
		    else \
			echo "Test \"$$bn\" starting ... failed." ; \
			diff -c $$bn.out $$bn.ou~ ; \
		    fi ; \
		else \
		    ${EMX} runtest.x $$bn.x < $$bn.in ; \
		fi ; \
	    else \
		if [ -r $$bn.out ] ; then \
		    ${EMX} runtest.x $$bn.x > $$bn.ou~ ; \
		    if cmp -s $$bn.out $$bn.ou~ ; then \
			echo "Test \"$$bn\" starting ... completed successfully." ; \
			rm $$bn.ou~ ; \
		    else \
			echo "Test \"$$bn\" starting ... failed." ; \
			diff -c $$bn.out $$bn.ou~ ; \
		    fi ; \
		else \
		    ${EMX} runtest.x $$bn.x ; \
		fi ; \
	    fi ; \
	    true ; \
	done

sources src source:
	@echo "${SOURCES}"

clean:
	rm -f core *.bak *.ckp *.x
	cp /dev/null name
	rm -f name.idb name.ats name.oid
	rm -f compile

# DO NOT DELETE THIS LINE -- make depend uses it
