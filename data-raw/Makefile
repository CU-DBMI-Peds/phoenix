include ../Makevars

RDAS := $(REPO_ROOT)/data/sepsis.rda $(REPO_ROOT)/data/phx.rda

all: $(RDAS)

$(REPO_ROOT)/data/%.rda: %.R
	$(RSCRIPT) $<
