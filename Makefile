include Makevars

PKG_ROOT ?= $(REPO_ROOT)

PKG_VERSION = $(shell awk '/^Version:/{print $$2; exit}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    = $(shell awk '/^Package:/{print $$2; exit}' $(PKG_ROOT)/DESCRIPTION)
PKG_TARBALL = $(PKG_NAME)_$(PKG_VERSION).tar.gz

BUILD_OPTIONS   ?=
CHECK_OPTIONS   ?=
INSTALL_OPTIONS ?=

SRC       = $(wildcard $(PKG_ROOT)/src/*.cpp)
RFILES    = $(wildcard $(PKG_ROOT)/R/*.R)
TESTS     = $(wildcard $(PKG_ROOT)/tests/*.R)
RAWDATAR  = $(wildcard $(PKG_ROOT)/data-raw/*.R)
VIGNETTES = $(addsuffix .Rmd, $(PKG_ROOT)/vignettes/$(notdir $(basename $(wildcard $(PKG_ROOT)/vignette-spinners/*.R))))

README_RMD         = $(PKG_ROOT)/README.Rmd
README_MD          = $(PKG_ROOT)/README.md
RBUILDIGNORE       = $(PKG_ROOT)/.Rbuildignore
CITATION           = $(PKG_ROOT)/inst/CITATION
DOCUMENT_STAMP     = $(PKG_ROOT)/.document.Rout
INSTALL_DEPS_STAMP = $(PKG_ROOT)/.install_dev_deps.Rout

.PHONY: all check site install covr clean

all: $(PKG_TARBALL)

################################################################################
# Build the package tarball.
$(PKG_TARBALL): $(INSTALL_DEPS_STAMP) $(DOCUMENT_STAMP) $(TESTS) $(RBUILDIGNORE)
	$(RCMD) build --md5 $(BUILD_OPTIONS) $(PKG_ROOT)

# Install/update dev dependencies; store console output in the stamp.
$(INSTALL_DEPS_STAMP): $(PKG_ROOT)/DESCRIPTION
	tmp="$@.tmp"; \
	trap '$(RM) "$$tmp"' EXIT; \
	$(RSCRIPT) -e $(REPOS) \
	  -e "if (!requireNamespace('pak', quietly=TRUE)) \
	       install.packages('pak', repos='$(CRAN)')" \
	  -e "options(warn=2)" \
	  -e "pak::local_install_dev_deps(root = '$(PKG_ROOT)')" \
	  > "$$tmp" 2>&1 && mv "$$tmp" "$@"

$(DOCUMENT_STAMP): $(RFILES) $(SRC) $(RAWDATAR) $(VIGNETTES) $(PKG_ROOT)/DESCRIPTION $(README_MD) $(CITATION) $(INSTALL_DEPS_STAMP)
	if [ -e "$(PKG_ROOT)/data-raw/Makefile" ]; then \
		$(MAKE) -C "$(PKG_ROOT)/data-raw/"; \
	else \
		echo "Nothing to do"; \
	fi
	$(RSCRIPT) -e "devtools::document('$(PKG_ROOT)')"
	@touch "$@"

$(README_MD): $(README_RMD)
	$(RSCRIPT) -e "devtools::load_all('$(PKG_ROOT)')"\
		-e "knitr::knit('$(README_RMD)', output = '$(README_MD)')"

check: $(PKG_TARBALL)
	$(RCMD) check $(CHECK_OPTIONS) $(PKG_TARBALL)

install: $(PKG_TARBALL)
	$(RCMD) INSTALL $(INSTALL_OPTIONS) $(PKG_TARBALL)

################################################################################
# Recipes for Vignettes
$(PKG_ROOT)/vignettes/%.Rmd : $(PKG_ROOT)/vignette-spinners/%.R
	$(R) -e "knitr::spin(hair = '$<', knit = FALSE)"
	mv $(basename $<).Rmd $@

################################################################################
covr-report-%.html : $(PKG_TARBALL) .covr
	$(R) \
		-e 'x <- covr::package_coverage(type = "$*")'\
		-e 'covr::report(x, file = "$@")'

covr-report-tests.html : $(PKG_TARBALL) .covr
	$(R) \
		-e 'x <- covr::package_coverage(type = "tests", function_exclusions = c("plot\\\\.", "print\\\\.", "\\\\.onLoad", "\\\\.onUnload"), line_exclusions = list("R/cpr-defunct.R"))'\
		-e 'covr::report(x, file = "$@")'

covr: covr-report-all.html covr-report-tests.html covr-report-examples.html covr-report-vignettes.html

.covr:
	$(RSCRIPT) -e $(REPOS) \
	  -e "if (!requireNamespace('covr', quietly=TRUE)) \
	       install.packages('covr', repos='$(CRAN)')"  \
	  -e "if (!requireNamespace('DT', quietly=TRUE)) \
	       install.packages('DT', repos='$(CRAN)')"  \
	  -e "if (!requireNamespace('htmltools', quietly=TRUE)) \
	       install.packages('htmltools', repos='$(CRAN)')"

site: $(PKG_TARBALL)
	$(R) -e "pkgdown::build_site()"

################################################################################
clean:
	$(RM) $(PKG_TARBALL)
	$(RM) -r $(PKG_NAME).Rcheck
	$(RM) $(DOCUMENT_STAMP) $(INSTALL_DEPS_STAMP)
	$(RM) $(PKG_ROOT)/vignettes/*.html
	$(RM) *.html
	$(RM) -r lib/*

################################################################################
## End of File
################################################################################
