.PHONY: dist clean test

VERSION := 0.4

clean:
	rm -f *.tar.gz

dist:
	# XXX: hardcodes a lot
	git archive --prefix=siteadd-$(VERSION)/ --format=tar.gz -o siteadd-$(VERSION).tar.gz HEAD addsite.sh rmsite.sh template-httpd.m4 template-fastcgi.m4 template-index.html.m4 README.md COPYING

test:
	# requires shellcheck, obviously
	# (it's Haskell, so don't expect it on i anytime soon)
	shellcheck addsite.sh
	shellcheck rmsite.sh
