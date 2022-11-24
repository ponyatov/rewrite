# var
MODULE = $(notdir $(CURDIR))
module = $(shell echo $(MODULE) | tr A-Z a-z)
OS     = $(shell uname -o|tr / _)
NOW    = $(shell date +%d%m%y)
REL    = $(shell git rev-parse --short=4 HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
PEPS   = E26,E302,E305,E401,E402,E701,E702

# tool
PY     = python3
PIP    = pip3
PEP    = autopep8

# src
Y  = $(MODULE).py
S += $(Y)

# format
.PHONY: format
format: tmp/format_py

tmp/format_py: $(Y)
	$(PEP) --ignore $(PEPS) -i $? && touch $@

# doc
.PHONY: doxy doc
doc: doxy
doxy: .doxygen
	rm -rf docs ; doxygen $< 1>/dev/null

# install
install update: doc
	sudo apt update
	sudo apt install -yu `cat apt.txt`
	$(PIP) install --user -U    pip autopep8 pytest
	$(PIP) install --user -U -r requirements.txt

# merge
MERGE  = Makefile README.md .clang-format .doxygen $(S)
MERGE += apt.txt requirements.txt
MERGE += .vscode bin doc lib inc src tmp

dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
	$(MAKE) doxy ; git add -f docs

shadow:
	git push -v
	git checkout $@
	git pull -v

release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
