PKG_ROOT    = .
PKG_VERSION = $(shell gawk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    = $(shell gawk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)

SRC       = $(wildcard $(PKG_ROOT)/src/*.cpp)
RFILES    = $(wildcard $(PKG_ROOT)/R/*.R)
TESTS     = $(wildcard $(PKG_ROOT)/tests/*.R)
RAWDATAR  = $(wildcard $(PKG_ROOT)/data-raw/*.R)
VIGNETTES = $(addsuffix .Rmd, $(PKG_ROOT)/vignettes/$(notdir $(basename $(wildcard $(PKG_ROOT)/vignette-spinners/*.R))))

.PHONY: all check site install clean

#all: $(PKG_NAME)_$(PKG_VERSION).tar.gz

################################################################################
# build the tar ball
$(PKG_NAME)_$(PKG_VERSION).tar.gz: .document.Rout $(TESTS) .Rbuildignore
	R CMD build --md5 $(build-options) $(PKG_ROOT)

.document.Rout: $(RFILES) $(SRC) $(RAWDATAR) $(VIGNETTES) $(PKG_ROOT)/DESCRIPTION README.md
	if [ -e "$(PKG_ROOT)/data-raw/Makefile" ]; then $(MAKE) -C $(PKG_ROOT)/data-raw/; else echo "Nothing to do"; fi
	Rscript --vanilla --quiet -e "devtools::document('$(PKG_ROOT)')"
	@touch $@

README.md : README.Rmd
	Rscript --vanilla -e "devtools::load_all('$(PKG_ROOT)')"\
		-e "knitr::knit('$(PKG_ROOT)/README.Rmd', output = 'README.md')"

check: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD check $(PKG_NAME)_$(PKG_VERSION).tar.gz

install: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD INSTALL $(PKG_NAME)_$(PKG_VERSION).tar.gz

################################################################################
# Recipes for Vignettes
$(PKG_ROOT)/vignettes/%.Rmd : $(PKG_ROOT)/vignette-spinners/%.R
	R --vanilla --quiet -e "knitr::spin(hair = '$<', knit = FALSE)"
	mv $(basename $<).Rmd $@

################################################################################
covr-report-%.html : $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R --vanilla --quiet \
		-e 'library(covr)'\
		-e 'x <- package_coverage(type = "$*")'\
		-e 'report(x, file = "$@")'

covr-report-tests.html : $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R --vanilla --quiet \
		-e 'library(covr)'\
		-e 'x <- package_coverage(type = "tests", function_exclusions = c("plot\\\\.", "print\\\\.", "\\\\.onLoad", "\\\\.onUnload"), line_exclusions = list("R/cpr-defunct.R"))'\
		-e 'report(x, file = "$@")'

covr : covr-report-all.html covr-report-tests.html covr-report-examples.html covr-report-vignettes.html

site: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R --vanilla --quiet -e "pkgdown::build_site()"

################################################################################
clean:
	$(RM) -f  $(PKG_NAME)_$(PKG_VERSION).tar.gz
	$(RM) -rf $(PKG_NAME).Rcheck
	$(RM) -f .document.Rout
	$(RM) -f src/*.o
	$(RM) -f src/*.so
	$(RM) -f vignettes/*.html
	$(RM) -f *.html

################################################################################
## End of File
################################################################################
