EMC=emc

TARGETS = \
	nonexist.x \
	assign.x \
	builtin1.x \
	class.x \
	conform.x \
	conform2.x \
	conform3.x \
	conform4.x \
	const.x \
	export.x \
	ident1.x \
	ident2.x \
	immut.x \
	lit1.x \
	lit2.x \
	lit3.x \
	lit4.x \
	multi.x \
	multi2.x \
	multi3.x \
	nontype.x \
	old1.x \
	old5.x \
	old6.x \
	ops1.x \
	ops2.x \
	ops3.x \
	ops4.x \
	shadow1.x \
	shadow2.x \
	signal.x \
	str.x \
	stat.x \
	subs.x \
	syn.x \
	tscope.x \
	type1.x \
	type2.x \
	type3.x \
	type4.x \
	type5.x \
	type6.x \
	type7.x \
	type8.x \
	type9.x \
	union.x \
	vec1.x \
	vec2.x

.SUFFIXES:
.SUFFIXES:	.x .m

.m.x:
	@echo Checking $*.m
	@-echo $*.m | $(EMC) > $*.res
	@rm -f $*.x
	@-if cmp -s $*.res $*.exp ; then rm $*.res; else diff -c $*.exp $*.res ; fi

all:	$(TARGETS)

nonexist.m:
	@true

clean:
	rm -f core *.bak *.ckp *.x *.res
