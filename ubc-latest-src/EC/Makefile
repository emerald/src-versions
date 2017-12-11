#
# EC Makefile
#

EMX = emx
EMC = emc

# To generate youtput for checking yacc's actions
# YACCVERBOSE = -v

all CP:	ident.m symbol.m \
	buffer.m iibtable.m envtype.m ids.m glblref.m sym.m opname.m \
	builtinl.m cpqueue.m nextoid.m cstring.m \
	scan.m newid.m ctcode.m sitable.m  \
	bytecode.m seq.m ontooid.m fielddcl.m param.m symdef.m atcode.m \
	opsig.m opdef.m assignst.m block.m symref.m setq.m constdcl.m \
	vardecl.m sugar.m atlit.m oblit.m wherewgt.m foutput.m \
	siiiatbl.m invcache.m primstat.m invoc.m comp.m xexport.m arg.m \
	assertst.m elsecls.m xclass.m selflit.m ifclause.m \
	ifstat.m enumlit.m exitstat.m exp.m fieldsel.m initdef.m loopstat.m \
	movestat.m newexp.m select.m procdef.m reclit.m \
	recovdef.m  retfail.m retstat.m \
	veclit.m subscrpt.m unaryexp.m \
	xfailure.m onearg.m \
	xunavail.m xview.m parse.m cp.m pt.m jc.m

emall:	scan.m parse.m

scan.m:	scanhead.m parsedef.m tokNames.m scantail.m
	rm -f scan.m
	cat scanhead.m parsedef.m tokNames.m scantail.m > scan.m
	chmod a-w scan.m

tokNames.m parsedef.m parse.m:	em_ecomp.y
	@echo "Expect no conflicts"
	emyacc -e ${YACCVERBOSE} em_ecomp.y
	mv -f ytab.h parsedef.m
	rm -f parse.m tokNames.m
	mv -f ytab.m parse.m
	MAKETN
	chmod -w parse.m parsedef.m tokNames.m

reset:
	rm -f CP CPIndex *.x
	rm -f name.idb name name.ats name.oid name.opd

dolinks:
	rm -f /tmp/CP /tmp/CPIndex /tmp/name /tmp/name.ats /tmp/name.oid /tmp/name.opd /tmp/name.idb
	ln -s /tmp/CPIndex CPIndex
	ln -s /tmp/CP CP
	ln -s /tmp/name name
	ln -s /tmp/name.ats name.ats
	ln -s /tmp/name.oid name.oid
	ln -s /tmp/name.opd name.opd
	ln -s /tmp/name.idb name.idb

src:
	@egrep '^[a-z]*\.m$$' input.? t | sed -e 's/^.*://' | sort

install:
	$(EMX) -C bestCP
	rm -f $(EMLIBDIR)/Compiler
	cp bestCP $(EMLIBDIR)/Compiler
	chmod -w $(EMLIBDIR)/Compiler

bestCP:	execCP
	echo >  xxinput  unset dogeneration
	echo >> xxinput  set dotypecheck
	echo >> xxinput  unset exporttree
	echo >> xxinput  set compilingbuiltins
	for x in Integer.m AOpVec.m AParamL.m AOpVecE.m AType.m Any.m Bitchunk.m Boolean.m COpVec.m COpVecE.m CType.m Char.m Cond.m Handler.m IState.m IVOfAny.m IVOfInt.m RISC.m String.m InStr.m Literal.m NLElem.m Nil.m Node.m NodeL.m OutStr.m RISA.m Real.m Signat.m Stub.m Time.m VOfChar.m VOfInt.m VOfAny.m VOfStr.m IVOfStr.m Direct.m ; do \
	    echo >> xxinput ../Builtins/$$x ; \
	done
	echo >> xxinput  set exporttree
	for x in IVec.m Vec.m Array.m Sequence.m ; do \
	    echo >> xxinput ../Builtins/$$x ; \
	done
	echo >> xxinput  unset compilingbuiltins
	echo >> xxinput  set dogeneration
	echo >> xxinput  set perfile
	echo >> xxinput  set generateconcurrent
	echo >> xxinput  checkpoint bestCP
	echo source xxinput | $(EMX) -O4m -v execCP
	rm xxinput

XCP:	
	echo >  xxinput  unset perfile
	echo >> xxinput  unset exporttree
	echo >> xxinput  set dotypecheck
	echo >> xxinput  unset docompilation
	echo >> xxinput  load name
	echo >> xxinput  source bt
	echo >> xxinput  checkpoint XCP
	echo source xxinput | $(EMC) -O8M
	rm xxinput

ffs_0:	reset
	@hostname
	@echo EMERALDROOT is $(EMERALDROOT)
	@echo EMERALDARCH is $(EMERALDARCH)
	@date
	echo >  xxinput  set compilingcompiler
	echo >> xxinput  unset dieonerror
	echo >> xxinput  unset perfile
	echo >> xxinput  unset exporttree
	echo >> xxinput  unset generateats
	echo >> xxinput  unset generateconcurrent
	echo >> xxinput  unset generateviewchecking
	echo >> xxinput  load name
	echo >> xxinput  unset docompilation

ffs_1standard:
	echo >> xxinput  unset dotypecheck

ffs_2standard:
	echo >> xxinput  source b

ffs_2special:
	echo >> xxinput	 source all_b

ffs_2fast:

ffs_3:
	echo >> xxinput  source input.0
	echo >> xxinput  source t
	echo >> xxinput  source input.1
	echo >> xxinput  source input.2
	echo >> xxinput  source input.3
	echo >> xxinput  source input.4
	echo >> xxinput  source input.5

ffs_4:
	csh -f -c "time $(EMC) -g1M -G2 -O8M -v" < xxinput

ffs_4big:
	csh -f -c "time $(EMC) -g1M -G2 -O20M -v" < xxinput

ffs_5:
	@date
	@rm xxinput

ffs:	ffs_0 ffs_1standard ffs_2standard ffs_3 ffs_4 ffs_5

# This one assumes that the installed compiler has the builtins already
# loaded, and so doesn't bother to do that again
fffs:	ffs_0 ffs_1standard ffs_2fast ffs_3 ffs_4 ffs_5

# This one uses the experimental compiler in this directory, and performs
# type checking as well

ffs_1typecheck:
	echo >> xxinput  set dotypecheck
	echo >> xxinput  set generateviewchecking

ffs_1typechecknoviews:
	echo >> xxinput  set dotypecheck

ffs_1abcon:
	echo >> xxinput  set useabcons

tffs:	ffs_0 ffs_1typecheck ffs_2fast ffs_3 ffs_4big ffs_5

ffs_1nodebug:
	echo >> xxinput  unset generatedebuginfo


# This one doesn't generate debug info
sfffs:	ffs_0 ffs_1nodebug ffs_2fast ffs_3 ffs_4 ffs_5

# This one sets useabcons, just for fun
affs:	ffs_0 ffs_1abcon ffs_2fast ffs_3 ffs_4big ffs_5

ftffs:	ffs_0 ffs_1typechecknoviews ffs_2fast ffs_3 ffs_4big ffs_5

stffs:	ffs_0 ffs_1typechecknoviews ffs_1nodebug ffs_2fast ffs_3 ffs_4big ffs_5
