QUARTO ?= quarto # /usr/local/bin/quarto
LATEXMK := latexmk
LATEXMKPDF := latexmk -gg -pdf

OPERATIONALPHX=operational-definition-phoenix-sepsis-criteria

.PHONY: all clean

all: ../references.bib $(OPERATIONALPHX).pdf

../references.bib: ../nbib2bib.bash ../nbibs/*.nbib
	$(MAKE) -C ../.. references

%.pdf: %.tex ../references.bib latex-header.tex
	$(LATEXMKPDF) $<

clean:
	$(LATEXMK) -C $(OPERATIONALPHX).tex
	$(RM) -f $(OPERATIONALPHX).bbl
