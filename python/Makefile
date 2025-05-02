PKG_NAME := $(shell gawk '/^name =/{print substr($$3,2,length($$3)-2)}' pyproject.toml)
PKG_VERSION := $(shell gawk '/^version =/{print substr($$3,2,length($$3)-2)}' pyproject.toml)

.PHONY: all deploy_testpypi clean

all : dist/$(PKG_NAME)-$(PKG_VERSION).tar.gz README.md

test:
	echo $(PKG_NAME)

dist/$(PKG_NAME)-$(PKG_VERSION).tar.gz : pyproject.toml LICENSE README.md phoenix/__init__.py phoenix/phoenix.py MANIFEST.in
	conda run -n phoenix-dev python -m build

deploy_testpypi: dist/$(PKG_NAME)-$(PKG_VERSION).tar.gz
	# this will only work if you have the correct api token in your ~/.pypirc file
	conda run -n phoenix-dev python -m twine upload --verbose --repository testpypi dist/*

deploy_pypi: dist/$(PKG_NAME)-$(PKG_VERSION).tar.gz
	# this will only work if you have the correct api token in your ~/.pypirc file
	conda run -n phoenix-dev python -m twine upload --verbose --repository pypi dist/*

README.md : README.Rmd
	Rscript --vanilla -e "knitr::knit('$<', output = '$@')"

clean :
	$(RM) -r dist
	$(RM) -r build
	$(RM) -r phoenix.egg-info

# NOTE: helpful resources:
# https://packaging.python.org/en/latest/tutorials/packaging-projects/
