OUT=masterthesis
BIBFILE=literature.bib

OUTPDF=$(OUT).pdf
BAKPDF=$(OUT)_bak.pdf

TEX=pdflatex
TEXFLAGS=

BIBTEX=bibtex
BIBFLAGS=

TIME=$(shell which time) -f '\nThis command took %e seconds'

all:
	make $(OUTPDF)
	make $(OUTPDF)
#	make $(OUTPDF) # is a third pass necessary?
	@echo "build successful. $(OUTPDF) created and copied to $(BAKPDF)"

continuous:
	latexrefre.sh

.PHONY: all always

.PRECIOUS: %.aux

%.aux: literature.bib always
	-$(BIBTEX) $@

%.pdf: %.tex %.aux always
	$(TIME) $(TEX) $(TEXFLAGS) $<
	cp $(OUTPDF) $(BAKPDF)

clean:
	rm -f *.aux $(OUT).{lof,log,log,lot,out,toc} $(OUTPDF) $(BAKPDF)
