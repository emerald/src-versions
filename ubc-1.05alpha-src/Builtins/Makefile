#
# Builtins Makefile
#

EMX = emx
EMC = emc

CRITICALSOURCES = \
	AType.m \
	Any.m \
	Boolean.m \
	Char.m \
	Cond.m \
	Integer.m \
	Nil.m \
	NLElem.m \
	NodeL.m \
	Handler.m \
	VOfAny.m \
	VOfChar.m \
	VOfInt.m \
	String.m \
	Node.m \
	Bitchunk.m \
	OutStr.m \
	InStr.m \
	Real.m \
	AParamL.m \
	AOpVecE.m \
	AOpVec.m \
	Signat.m \
	COpVecE.m \
	COpVec.m \
	IVOfInt.m \
	CType.m \
	RISC.m \
	IState.m \
	Time.m \
	Direct.m \
	IVOfAny.m \
	RISA.m \
	Stub.m \
	Literal.m \
	IVOfStr.m \
	VOfStr.m \
	RDirect.m

EMBEDDEDSOURCES = \
	AType.m \
	Any.m \
	Boolean.m \
	Char.m \
	Cond.m \
	Integer.m \
	Nil.m \
	NLElem.m \
	NodeL.m \
	Handler.m \
	VOfAny.m \
	VOfChar.m \
	VOfInt.m \
	String.m \
	Node.m \
	Bitchunk.m \
	OutStr.m \
	InStr.m \
	Real.m \
	AParamL.m \
	AOpVecE.m \
	AOpVec.m \
	Signat.m \
	COpVecE.m \
	COpVec.m \
	IVOfInt.m \
	CType.m \
	RISC.m \
	IState.m \
	Time.m \
	Direct.m \
	IVOfAny.m \
	RISA.m \
	Stub.m \
	Literal.m \
	IVOfStr.m \
	VOfStr.m


OTHERSOURCES = \
	Array.m \
	Sequence.m \
	Vec.m \
	IVec.m

all:	$(CRITICALSOURCES) $(OTHERSOURCES)
	rm -f CP CPIndex
	rm -f name.ats name.idb name name.opd name.oid
	cp /dev/null name
	cp $(EMLIBDIR)/opoid name.opd ; chmod +w name.opd
	echo >  xxinput  unset tracepasses
	echo >> xxinput  unset docompilation
	echo >> xxinput  unset dotypecheck
	echo >> xxinput  unset perfile
	echo >> xxinput  set compilingbuiltins
	echo >> xxinput  set exporttree
	echo >> xxinput  load name
	for x in $(CRITICALSOURCES) ; do \
	    echo >> xxinput  $$x ;\
	done
	echo source xxinput | $(EMC) -O4m
	rm -f xxinput

embeddedall:	$(EMBEDDEDSOURCES) $(OTHERSOURCES)
	rm -f CP CPIndex
	rm -f name.idb name name.opd name.oid
	cp /dev/null name
	cp $(EMLIBDIR)/opoid name.opd ; chmod +w name.opd
	echo >  xxinput  unset tracepasses
	echo >> xxinput  unset docompilation
	echo >> xxinput  unset dotypecheck
	echo >> xxinput  unset perfile
	echo >> xxinput  unset generatedebuginfo
	echo >> xxinput  set compilingbuiltins
	echo >> xxinput  set exporttree
	echo >> xxinput  load name
	for x in $(EMBEDDEDSOURCES) ; do \
	    echo >> xxinput  $$x ;\
	done
	echo source xxinput | $(EMC) -O4m
	rm -f xxinput

install:
	$(EMX) -B -C -b CP
	rm -f $(EMLIBDIR)/Builtins
	cp CP $(EMLIBDIR)/Builtins
	chmod -w $(EMLIBDIR)/Builtins
	cp name.opd $(EMLIBDIR)/opoid

embeddedinstall:
	$(EMX) -B -C -b CP
	rm -f $(EMLIBDIR)/EBuiltins
	cp CP $(EMLIBDIR)/EBuiltins
	chmod -w $(EMLIBDIR)/EBuiltins
	cp name.opd $(EMLIBDIR)/opoid

VOfChar.m: Vec.m vec-ed
	csh vec-ed Vec.m VectorOfChar Character 16 VOfChar.m

VOfAny.m: Vec.m vec-ed
	csh vec-ed Vec.m VectorOfAny Any 28 VOfAny.m

VOfInt.m: Vec.m vec-ed
	csh vec-ed Vec.m VectorOfInt Integer 1e VOfInt.m

VOfStr.m:	Vec.m vec-ed
	csh vec-ed Vec.m VectorOfString String 2a VOfStr.m

NodeL.m:	IVec.m vec-ed
	csh vec-ed IVec.m NodeList NodeListElement 0f NodeL.m

COpVec.m:	IVec.m vec-ed
	csh vec-ed IVec.m COpVector COpVectorE 19 COpVec.m

AOpVec.m:	IVec.m vec-ed
	csh vec-ed IVec.m AOpVector AOpVectorE 1b AOpVec.m

AParamL.m:	IVec.m vec-ed
	csh vec-ed IVec.m AParamList Signature 1d AParamL.m

IVOfAny.m:	IVec.m vec-ed
	csh vec-ed IVec.m ImmutableVectorOfAny Any 21 IVOfAny.m

IVOfStr.m:	IVec.m vec-ed
	csh vec-ed IVec.m ImmutableVectorOfString String 29 IVOfStr.m

IVOfInt.m:	IVec.m vec-ed
	csh vec-ed IVec.m ImmutableVectorOfInt Integer 23 IVOfInt.m

Literal.m:	IVec.m vec-ed
	csh vec-ed IVec.m LiteralList Integer 27 Literal.m

clean:
	rm -f *.bak .emacs_[0-9]* *.ckp 

