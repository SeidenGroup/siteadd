.PHONY: all dist clean test install

CC := gcc
# XXX: Do we put libsiteadd-c in -I?
CFLAGS := -std=gnu11 -Wall -Werror -gxcoff -maix64 -O2
LDFLAGS :=

QTI_PGM := qtimzon2iana/qtimzon2iana
QTI_OBJ := qtimzon2iana/qwcrtvtz.o qtimzon2iana/qwcrsval.o libsiteadd-c/ebcdic.o qtimzon2iana/main.o
QTI_DEPS := qtimzon2iana/qwcrtvtz.h libsiteadd-c/ebcdic.h libsiteadd-c/errc.h

GRC_PGM := generate-resolv/generate-resolv
GRC_OBJ := generate-resolv/QtocRtvTCPA.o libsiteadd-c/ebcdic.o generate-resolv/main.o
GRC_DEPS := generate-resolv/QtocRtvTCPA.h libsiteadd-c/ebcdic.h libsiteadd-c/errc.h

# XXX: Hardcoded in scripts
PREFIX := /QOpenSys/pkgs
VERSION := 0.13

all: $(QTI_PGM) $(GRC_PGM)

clean:
	rm -f *.tar.gz $(QTI_PGM) $(QTI_OBJ) $(GRC_PGM) $(GRC_OBJ)

dist:
	# XXX: hardcodes a lot
	git archive --prefix=siteadd-$(VERSION)/ --format=tar.gz -o siteadd-$(VERSION).tar.gz HEAD *.sh *.php qtimzon2iana/ generate-resolv/ libsiteadd-c/ template/ template-legacy-db/ README.md COPYING Makefile

test:
	# requires shellcheck, obviously
	# (it's Haskell, so don't expect it on i anytime soon)
	# And ignore SC1091 since it'll complain about a path that only exists when installed on i
	shellcheck -e SC1091 libsiteadd.sh \
	 addsite.sh \
	 rmsite.sh \
	 dspsite.sh \
	 toggle-db-script.sh \
	 toggle-autostart.sh \
	 transform-php-config.sh \
	 update-ini-for-nortl.sh

install: $(QTI_PGM)
	echo "Installing to $(DESTDIR)$(PREFIX)"
	install -D -m 755 addsite.sh $(DESTDIR)$(PREFIX)/bin/addsite
	install -D -m 755 rmsite.sh $(DESTDIR)$(PREFIX)/bin/rmsite
	install -D -m 755 dspsite.sh $(DESTDIR)$(PREFIX)/bin/dspsite
	install -D -m 755 toggle-db-script.sh $(DESTDIR)$(PREFIX)/bin/toggle-db
	install -D -m 755 toggle-autostart.sh $(DESTDIR)$(PREFIX)/bin/toggle-autostart
	install -D -m 755 $(QTI_PGM) $(DESTDIR)$(PREFIX)/bin/qtimzon2iana
	install -D -m 755 $(GRC_PGM) $(DESTDIR)$(PREFIX)/bin/generate-resolv
	install -D -m 755 libsiteadd.sh $(DESTDIR)$(PREFIX)/lib/siteadd/libsiteadd.sh
	install -D -m 755 canlisten.php $(DESTDIR)$(PREFIX)/bin/canlisten
	install -D -m 755 transform-php-config.sh $(DESTDIR)$(PREFIX)/bin/transform-php-config
	install -D -m 755 update-ini-for-nortl.sh $(DESTDIR)$(PREFIX)/bin/update-ini-for-nortl
	# Default template
	install -D -m 644 template/template-httpd.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/template-httpd.m4
	install -D -m 644 template/template-fastcgi.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/template-fastcgi.m4
	install -D -m 644 template/htdocs-templates $(DESTDIR)$(PREFIX)/share/siteadd/template/htdocs-templates
	install -D -m 644 template/htdocs/index.php.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/htdocs/index.php.m4
	install -D -m 644 template/phpconf-7.3/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-7.3/php.ini.m4
	install -D -m 644 template/phpconf-7.4/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-7.4/php.ini.m4
	install -D -m 644 template/phpconf-8.0/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.0/php.ini.m4
	install -D -m 644 template/phpconf-8.1/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.1/php.ini.m4
	install -D -m 644 template/phpconf-8.2/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.2/php.ini.m4
	install -D -m 644 template/phpconf-8.3/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.3/php.ini.m4
	install -D -m 644 template/phpconf-7.3/conf.d/dummy.txt $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-7.3/conf.d/dummy.txt
	install -D -m 644 template/phpconf-7.4/conf.d/dummy.txt $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-7.4/conf.d/dummy.txt
	install -D -m 644 template/phpconf-8.0/conf.d/dummy.txt $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.0/conf.d/dummy.txt
	install -D -m 644 template/phpconf-8.1/conf.d/dummy.txt $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.1/conf.d/dummy.txt
	install -D -m 644 template/phpconf-8.2/conf.d/dummy.txt $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.2/conf.d/dummy.txt
	install -D -m 644 template/phpconf-8.3/conf.d/dummy.txt $(DESTDIR)$(PREFIX)/share/siteadd/template/phpconf-8.3/conf.d/dummy.txt
	# Legacy DB template
	install -D -m 755 template-legacy-db/preflight.sh $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/preflight.sh
	install -D -m 644 template-legacy-db/template-httpd.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/template-httpd.m4
	install -D -m 644 template-legacy-db/template-fastcgi.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/template-fastcgi.m4
	install -D -m 644 template-legacy-db/htdocs-templates $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/htdocs-templates
	install -D -m 644 template-legacy-db/htdocs/index.php.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/htdocs/index.php.m4
	install -D -m 644 template-legacy-db/phpconf-7.3/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.3/php.ini.m4
	install -D -m 644 template-legacy-db/phpconf-7.4/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.4/php.ini.m4
	install -D -m 644 template-legacy-db/phpconf-8.0/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.0/php.ini.m4
	install -D -m 644 template-legacy-db/phpconf-8.1/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.1/php.ini.m4
	install -D -m 644 template-legacy-db/phpconf-8.2/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.2/php.ini.m4
	install -D -m 644 template-legacy-db/phpconf-8.3/php.ini.m4 $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.3/php.ini.m4
	install -D -m 644 template-legacy-db/phpconf-7.3/conf.d/20-odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.3/conf.d/20-odbc.ini
	install -D -m 644 template-legacy-db/phpconf-7.3/conf.d/30-pdo_odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.3/conf.d/30-pdo_odbc.ini
	install -D -m 644 template-legacy-db/phpconf-7.3/conf.d/99-ibm_db2.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.3/conf.d/99-ibm_db2.ini
	install -D -m 644 template-legacy-db/phpconf-7.3/conf.d/99-pdo_ibm.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.3/conf.d/30-pdo_idm.ini
	install -D -m 644 template-legacy-db/phpconf-7.4/conf.d/20-odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.4/conf.d/20-odbc.ini
	install -D -m 644 template-legacy-db/phpconf-7.4/conf.d/30-pdo_odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.4/conf.d/30-pdo_odbc.ini
	install -D -m 644 template-legacy-db/phpconf-7.4/conf.d/99-ibm_db2.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.4/conf.d/99-ibm_db2.ini
	install -D -m 644 template-legacy-db/phpconf-7.4/conf.d/99-pdo_ibm.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-7.4/conf.d/30-pdo_idm.ini
	install -D -m 644 template-legacy-db/phpconf-8.0/conf.d/20-odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.0/conf.d/20-odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.0/conf.d/30-pdo_odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.0/conf.d/30-pdo_odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.0/conf.d/99-ibm_db2.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.0/conf.d/99-ibm_db2.ini
	install -D -m 644 template-legacy-db/phpconf-8.0/conf.d/99-pdo_ibm.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.0/conf.d/30-pdo_idm.ini
	install -D -m 644 template-legacy-db/phpconf-8.1/conf.d/20-odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.1/conf.d/20-odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.1/conf.d/30-pdo_odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.1/conf.d/30-pdo_odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.1/conf.d/99-ibm_db2.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.1/conf.d/99-ibm_db2.ini
	install -D -m 644 template-legacy-db/phpconf-8.1/conf.d/99-pdo_ibm.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.1/conf.d/30-pdo_idm.ini
	install -D -m 644 template-legacy-db/phpconf-8.2/conf.d/20-odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.2/conf.d/20-odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.2/conf.d/30-pdo_odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.2/conf.d/30-pdo_odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.2/conf.d/99-ibm_db2.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.2/conf.d/99-ibm_db2.ini
	install -D -m 644 template-legacy-db/phpconf-8.2/conf.d/99-pdo_ibm.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.2/conf.d/30-pdo_idm.ini
	install -D -m 644 template-legacy-db/phpconf-8.3/conf.d/20-odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.3/conf.d/20-odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.3/conf.d/30-pdo_odbc.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.3/conf.d/30-pdo_odbc.ini
	install -D -m 644 template-legacy-db/phpconf-8.3/conf.d/99-ibm_db2.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.3/conf.d/99-ibm_db2.ini
	install -D -m 644 template-legacy-db/phpconf-8.3/conf.d/99-pdo_ibm.ini $(DESTDIR)$(PREFIX)/share/siteadd/template-legacy-db/phpconf-8.3/conf.d/30-pdo_idm.ini

$(QTI_OBJ): %.o : %.c $(QTI_DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(QTI_PGM): $(QTI_OBJ)
	$(CC) -o $@ $^ /QOpenSys/usr/lib/libiconv.a $(CFLAGS) $(LDFLAGS)

# XXX: How much of this can be deduped?
$(GRC_OBJ): %.o : %.c $(GRC_DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(GRC_PGM): $(GRC_OBJ)
	$(CC) -o $@ $^ /QOpenSys/usr/lib/libiconv.a $(CFLAGS) $(LDFLAGS)
