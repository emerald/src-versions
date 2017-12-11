# Makefile for creating the Emerald Report

PSTEX = pstex

.SUFFIXES:
.SUFFIXES:	.ps .dvi .tex

.dvi.ps:
	dvi2ps $*

SOURCE  = Report

OTHERSOURCES = manytoone.epsf

SOURCES = \
	Report.tex \
	builtins.tex \
	declarations.tex \
	expressions.tex \
	lexical.tex \
	objects.tex \
	operations.tex \
	reliability.tex \
	reserved.tex \
	statements.tex \
	syntax.tex \
	types.tex \
	uwtitle.tex

# PRINTER is the name of the ps style printer to use.
PRINTER =  lw244

# MAIN is the name of the main file to be latex'ed. (no .tex suffix)
MAIN = 		Report
DIR  =		/usr/em/Language/Report


${SOURCE}.dvi:	${SOURCES}
	latex ${SOURCE}

spell:		${SOURCES}
	spell ${SOURCES}

bib:	
	-bibtex ${SOURCE} < /dev/null
	-@if egrep -s bibitem ${SOURCE}.bbl;then true;else cp /dev/null ${SOURCE}.bbl;fi

full:	${SOURCES}
	latex ${SOURCE}
	-bibtex ${SOURCE}
	-@if egrep -s bibitem ${SOURCE}.bbl;then true;else cp /dev/null ${SOURCE}.bbl;fi
	latex ${SOURCE}
	latex ${SOURCE}

print:
	echo "Try this on June, twit!"
	echo "dvi2ps ${SOURCE} | lpr"
#	lpr -P${PRINTER} -r ${SOURCE}.ps

release:
	ci -f -mFinalRelease1 ${SOURCES} < /dev/null
	co -l ${SOURCES} < /dev/null

ci:
	ci ${SOURCES} < /dev/null

co:
	co -l ${SOURCES} < /dev/null

clean:
	rm -f *.aux *.bbl *.blg *.toc *.lot *.log *.lof *.dvi *.ps \
		*.log *.bak *.ckp
