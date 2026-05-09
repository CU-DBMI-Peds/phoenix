include ../Makevars

PY_PKG_NAME    := $(shell awk -F ' *= *' '$$1 == "name" {gsub(/"/, "", $$2); print $$2; exit}' pyproject.toml)
PY_PKG_VERSION := $(shell awk -F ' *= *' '$$1 == "version" {gsub(/"/, "", $$2); print $$2; exit}' pyproject.toml)

.PHONY: all test deploy_testpypi deploy_pypi clean

all: dist/$(PY_PKG_NAME)-$(PY_PKG_VERSION).tar.gz README.md

test:
	echo $(PY_PKG_NAME)

dist/$(PY_PKG_NAME)-$(PY_PKG_VERSION).tar.gz: pyproject.toml LICENSE README.md phoenix/__init__.py phoenix/phoenix.py MANIFEST.in
	conda run -n phoenix-dev python -m build

deploy_testpypi: dist/$(PY_PKG_NAME)-$(PY_PKG_VERSION).tar.gz
	# This requires the correct API token in ~/.pypirc.
	conda run -n phoenix-dev python -m twine upload --verbose --repository testpypi dist/*

deploy_pypi: dist/$(PY_PKG_NAME)-$(PY_PKG_VERSION).tar.gz
	# This requires the correct API token in ~/.pypirc.
	conda run -n phoenix-dev python -m twine upload --verbose --repository pypi dist/*

README.md: README.Rmd
	$(RSCRIPT) -e "knitr::knit('$<', output = '$@')"

clean:
	$(RM) -r dist
	$(RM) -r build
	$(RM) -r *.egg-info

# NOTE: helpful resources:
# https://packaging.python.org/en/latest/tutorials/packaging-projects/
