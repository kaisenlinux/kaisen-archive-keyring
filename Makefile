GPGLIST := $(patsubst active-keys/kaisen-%,trusted.gpg/kaisen-archive-%.gpg,$(wildcard active-keys/kaisen-*))
BUILDAREA := trusted.gpg/build-area
GPG_OPTIONS := --no-options --no-default-keyring --no-auto-check-trustdb --trustdb-name ./trustdb.gpg

build: keyrings/kaisen-archive-keyring.gpg $(GPGLIST)

keyrings/kaisen-archive-keyring.gpg: active-keys/index
	mkdir -p keyrings
	jetring-build -I $@ active-keys
	gpg ${GPG_OPTIONS} --no-keyring --import-options import-export --import < $@ > $@.tmp
	mv -f $@.tmp $@

$(GPGLIST) :: trusted.gpg/kaisen-archive-%.gpg : active-keys/kaisen-% active-keys/index
	mkdir -p $(BUILDAREA) trusted.gpg
	grep -F $(shell basename $<) -- active-keys/index > $(BUILDAREA)/index
	cp $< $(BUILDAREA)
	jetring-build -I $@ $(BUILDAREA)
	rm -rf $(BUILDAREA)
	gpg ${GPG_OPTIONS} --no-keyring --import-options import-export --import < $@ > $@.tmp
	mv -f $@.tmp $@

clean:
	rm -rf keyrings trusted.gpg

install: build
	install -d $(DESTDIR)/usr/share/keyrings/
	cp trusted.gpg/*.gpg $(DESTDIR)/usr/share/keyrings/
	cp keyrings/*.gpg $(DESTDIR)/usr/share/keyrings/

.PHONY: clean build install
