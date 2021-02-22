.PHONY: dist clean test

VERSION := 0.5

clean:
	rm -f *.tar.gz

dist:
	# XXX: hardcodes a lot
	git archive --prefix=siteadd-$(VERSION)/ --format=tar.gz -o siteadd-$(VERSION).tar.gz HEAD addsite.sh rmsite.sh template/ template-legacy-db/ README.md COPYING

test:
	# requires shellcheck, obviously
	# (it's Haskell, so don't expect it on i anytime soon)
	shellcheck addsite.sh
	shellcheck rmsite.sh
