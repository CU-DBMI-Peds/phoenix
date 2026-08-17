QUARTO ?= quarto # /usr/local/bin/quarto
LATEXMK := latexmk
LATEXMKPDF := latexmk -gg -pdf

OPERATIONALPHX=operational-definition-phoenix-sepsis-criteria

.PHONY: all clean

all: $(OPERATIONALPHX).pdf

%.pdf: %.tex ../references.bib latex-header.tex
	$(LATEXMKPDF) $<

clean:
	$(LATEXMK) -C $(OPERATIONALPHX).tex
	$(RM) -f $(OPERATIONALPHX).bbl
