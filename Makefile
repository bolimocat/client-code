
# Copyright (c) 2003-2010, Andrew Dunstan

# See accompanying License file for license details

ALLPERLFILES = $(shell find . \( -name '*.pl' -o -name '*.pm' \) -print | sed 's!\./!!') build-farm.conf

# these are the explicitly selected perl files that will go in a 
# release tarball
PERLFILES = run_build.pl run_web_txn.pl run_branches.pl \
	update_personality.pl setnotes.pl \
	build-farm.conf  \
	PGBuild/SCM.pm PGBuild/Options.pm PGBuild/WebTxn.pm \
	PGBuild/Modules/Skeleton.pm \
	PGBuild/Modules/TestUpgrade.pm \
	PGBuild/Modules/FileTextArrayFDW.pm \
	PGBuild/Modules/TestDecoding.pm \
	PGBuild/Modules/TestCollateLinuxUTF8.pm

OTHERFILES = License README

RELEASE_FILES = $(PERLFILES) $(OTHERFILES)

ALLFILES = $(ALLPERLFILES) $(OTHERFILES)

CREL := $(if $(REL),$(strip $(subst .,_, $(REL))),YOU_NEED_A_RELEASE)

.PHONY: tag
tag:
	@test -n "$(REL)" || (echo Missing REL && exit 1)
	sed -i -e "s/VERSION = '[^']*';/VERSION = 'REL_$(REL)';/" $(ALLFILES)
	git commit -a -m 'Mark Release '$(REL)
	git tag -m 'Release $(REL)' REL_$(CREL)
	@echo Now do: git push --tags origin master

.PHONY: release
release:
	@test -n "$(REL)" || (echo Missing REL && exit 1)
	@echo REL = $(CREL)
	mkdir build-farm-$(REL)
	tar -cf - $(RELEASE_FILES) | tar -C build-farm-$(REL) -xf -
	tar -z -cf build-farm-$(CREL).tgz build-farm-$(REL)
	rm -rf build-farm-$(REL)

tidy:
	perltidy -b -bl -nsfs -naws -l=80 -ole=unix $(ALLPERLFILES) 

