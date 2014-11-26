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

allvariants: always
	make disabledraft
	make resetoptions
	make all
	cp $(OUTPDF) $(OUT)_online.pdf
	make resetoptions
	make disabletablefix
	make all
	cp $(OUTPDF) $(OUT)_online_notablefix.pdf
	make resetoptions
	make disablecolorlinks
	make all
	cp $(OUTPDF) $(OUT)_print.pdf
	make resetoptions
	make disablecolorlinks
	make disabletablefix
	make all
	cp $(OUTPDF) $(OUT)_print_notablefix.pdf

continuous:
	latexrefre.sh

resetoptions: $(OUT).tex always
	sed -r -i -e 's/^\s*%*\s*(\\[a-z]+(true|false))\s*$$/\1/' -e 's/^\\[a-z]+(true|false)$$/%% &/' $<
# TODO: reset draft mode?

# TODO add complementary commands
disablecolorlinks: $(OUT).tex always
	sed -r -i -e 's/^%% (\\paperonlytrue)$$/\1/' $<

enabletest: $(OUT).tex always
	sed -r -i -e 's/^%% (\\testonlytrue)$$/\1/' $<

disabletablefix: $(OUT).tex always
	sed -r -i -e 's/^%% (\\colortblfixfalse)$$/\1/' $<

enabledraft: $(OUT).tex always
	sed -r -i -e 's/^\s*%*\s*draft\s*,\s*$$/  draft,/' $<

disabledraft: $(OUT).tex always
	sed -r -i -e 's/^\s*%*\s*draft\s*,\s*$$/%% draft,/' $<

.PHONY: all always

.PRECIOUS: %.aux

%.aux: literature.bib always
	-$(BIBTEX) $@

%.pdf: %.tex %.aux always
	$(TIME) $(TEX) $(TEXFLAGS) $<
	cp $(OUTPDF) $(BAKPDF)

clean:
	rm -f *.aux $(OUT).{lof,log,log,lot,out,toc} $(OUTPDF) $(BAKPDF)
