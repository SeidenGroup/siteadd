.PHONY: dist clean

VERSION := 0.3

clean:
	rm -f *.tar.gz`

dist:
	# XXX: hardcodes a lot
	git archive --prefix=siteadd-$(VERSION)/ --format=tar.gz -o siteadd-$(VERSION).tar.gz HEAD addsite.sh rmsite.sh template-httpd.m4 template-fastcgi.m4 template-index.html.m4
