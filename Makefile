OUT=masterthesis
BIBFILE=literature.bib
VARIANTPREFIX=masterarbeit_erik_e_lorenz

OUTPDF=$(OUT).pdf
BAKPDF=$(OUT)_bak.pdf

TEX=pdflatex
TEXFLAGS=--halt-on-error --interaction=nonstopmode

BIBTEX=bibtex
BIBFLAGS=

TIME=$(shell which time) -f '\nThis command took %e seconds'

all:
	make $(OUTPDF)
	make $(OUTPDF)
#	make $(OUTPDF) # is a third pass necessary?
	@echo "build successful. $(OUTPDF) created and copied to $(BAKPDF)"

allvariants:
	make printvariants
	make onlinevariants

printvariants:
	make resetvariants
	make disablecolorlinks
	make all
	cp $(OUTPDF) $(VARIANTPREFIX)_print.pdf
	make resetvariants
	make disablecolorlinks
	make disabletablefix
	make all
	cp $(OUTPDF) $(VARIANTPREFIX)_print_notablefix.pdf
	make resetvariants
	make disablecolorlinks
	make disabletablefix
	make disablerowcolors
	make all
	cp $(OUTPDF) $(VARIANTPREFIX)_print_norowcolors.pdf

onlinevariants: resetvariants
	make resetvariants
	make all
	cp $(OUTPDF) $(VARIANTPREFIX)_online.pdf
	make resetvariants
	make disabletablefix
	make all
	cp $(OUTPDF) $(VARIANTPREFIX)_online_notablefix.pdf
	make resetvariants
	make disabletablefix
	make disablerowcolors
	make all
	cp $(OUTPDF) $(VARIANTPREFIX)_online_norowcolors.pdf

resetvariants:
	make clean
	make disabledraft
	make resetoptions

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

disablerowcolors: $(OUT).tex always
	sed -r -i -e 's/^%% (\\rowcolorsfalse)$$/\1/' $<

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
