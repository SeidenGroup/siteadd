#!/usr/bin/env bash
# Create HTTP server and populate PHP config for it
# Copyright (C) 2020 Seiden Group
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -euo pipefail

usage() {
	echo "Usage: $0 -p port -n site_name [-h http_template_file] [-f fastcgi_template_file] [-H html_template_file] [-I] [-Y|-N]"
	echo ""
	echo "Simplest usage: $0 -p port -n site_name"
	echo ""
	echo "Options:"
	echo "  -p port: Set the port number for the web site."
	echo "           This must be unique."
	echo "  -n name: The name of the site. This must be ten characters"
	echo "           or less, and meet the traditional naming rules for"
	echo "           for IBM i physical file members."
	echo "  -I: Make a separate directory for PHP INI files."
	echo "      PHP INIs will then be in /www/sitename/phpconf."
	echo "      Said INIs will be copied from the shared PHP etc dir."
	echo "      The default otherwise is to use said shared PHP etc dir."
	echo "  -Y: If the site should start automatically. Default."
	echo "  -N: If the site should not start automatically."
	echo "  -h http_template_file: Override what template is used for httpd.conf."
	echo "  -H html_template_file: Override what template is used for index.html."
	echo "  -f fastcgi_template_file: Override what template is used for fastcgi.conf."
	exit 255
}

# XXX: It might be worth considering making this take a directory parameter instead.
TMPL_HTTP="/QOpenSys/pkgs/share/siteadd/template-httpd.m4"
TMPL_FCGI="/QOpenSys/pkgs/share/siteadd/template-fastcgi.m4"
TMPL_HTML="/QOpenSys/pkgs/share/siteadd/template-index.html.m4"
MAKE_ETCPHP=no
AUTOSTART=" -AutoStartY"

while getopts ":p:n:h:H:f:YNI" o; do
	case "${o}" in
		"p")
			SITE_PORT=${OPTARG}
			if ! [[ "$SITE_PORT" =~ ^[0-9]*$ ]] ; then
				echo "The site port isn't a number."
				exit 6
			fi
			# above regex forces positive integer, so negative can't happen
			if [ "$SITE_PORT" -gt 65535 ]; then
				# max port number
				echo "The site port is greater than 65535."
				exit 7
			fi
			;;
		"n")
			SITE_NAME=${OPTARG}
			if [ -z "${#SITE_NAME}" ]; then
				echo "The site name is empty."
				exit 8
			fi
			# XXX: What limitations does HTTPA have on names?
			if [ "${#SITE_NAME}" -gt 10 ]; then
				echo "The site name is longer than 10 characters."
				exit 9
			fi
			;;
		"h")
			TMPL_HTTP=${OPTARG}
			;;
		"H")
			TMPL_HTML=${OPTARG}
			;;
		"f")
			TMPL_FCGI=${OPTARG}
			;;
		"I")
			MAKE_ETCPHP=yes
			;;
		"Y")
			# leading space is so we don't get a trailing space
			# at the PFM line
			AUTOSTART=" -AutoStartY"
			;;
		"N")
			AUTOSTART=" -AutoStartN"
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

# just make sure all our args are set.
# unfortunately bash doesn't like compounding these, so sep lines.
if ! [[ -v SITE_NAME ]]; then
	usage
fi
if ! [[ -v SITE_PORT ]]; then
	usage
fi

if [ ! -f "$TMPL_HTTP" ]; then
	echo "The HTTPd template \"$TMPL_HTTP\" doesn't exist."
	exit 4
fi
if [ ! -f "$TMPL_FCGI" ]; then
	echo "The FastCGI template \"$TMPL_FCGI\" doesn't exist."
	exit 5
fi
if [ ! -f "$TMPL_HTML" ]; then
	echo "The default HTML page template \"$TMPL_HTML\" doesn't exist."
	exit 11
fi

if [ "$(uname)" != "OS400" ]; then
	echo "Hey, this isn't i!"
	exit 10
fi

PF_MEMBER="/QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/$SITE_NAME.MBR"
# slashes are appended as needed
APACHEDIR="/www/$SITE_NAME"
if [ "$MAKE_ETCPHP" = "yes" ]; then
	ETCPHPDIR="$APACHEDIR/phpconf"
else
	ETCPHPDIR="/QOpenSys/etc/php"
fi

# these are case-insensitive... very much so
if [ -e "$PF_MEMBER" ]; then
	echo "The site already is in the physical file."
	exit 1
fi

if [ -d "$APACHEDIR" ]; then
	echo "The site already has the IFS WWW directory."
	exit 2
fi

# XXX: Is this the convention we want to rely on?
if [ -d "$ETCPHPDIR" ] && [ "$MAKE_ETCPHP" = "yes" ]; then
	echo "The site already has the IFS PHP directory."
	exit 3
fi
echo " ** Verified existing config"

# Create entries 
system "addpfm file(qusrsys/qatmhinstc) mbr($SITE_NAME)"
Rfile -w "$PF_MEMBER" << EOF
-apache -d /www/$SITE_NAME -f conf/httpd.conf$AUTOSTART
EOF
echo " ** Added PFM for HTTPd"

# Create /www directory
for dir in {logs,conf,htdocs}; do
	mkdir -p "$APACHEDIR/$dir"
done
echo " ** Made directories for web server"

# XXX: wrapper for m4?
m4 -D "xSITE_NAME=$SITE_NAME" -D "xPHPDIR=$ETCPHPDIR" -D "xWWWDIR=$APACHEDIR" -D "xPORT=$SITE_PORT" "$TMPL_HTTP" > "$APACHEDIR/conf/httpd.conf"
m4 -D "xSITE_NAME=$SITE_NAME" -D "xPHPDIR=$ETCPHPDIR" -D "xWWWDIR=$APACHEDIR" -D "xPORT=$SITE_PORT" "$TMPL_FCGI" > "$APACHEDIR/conf/fastcgi.conf"
m4 -D "xSITE_NAME=$SITE_NAME" -D "xPHPDIR=$ETCPHPDIR" -D "xWWWDIR=$APACHEDIR" -D "xPORT=$SITE_PORT" "$TMPL_HTML" > "$APACHEDIR/htdocs/index.html"
cat > "$APACHEDIR/htdocs/phpinfo.php" << EOF
<?php

phpinfo();
EOF
echo " ** Filled in templates"

if [ "$MAKE_ETCPHP" = "yes" ]; then
	# Basically copy over the existing PHP config
	# XXX: Do we need to change it
	cp -R /QOpenSys/etc/php "$ETCPHPDIR"
	echo " ** Made directories for PHP"
fi

# Set authorities (can't set ACLs from PASE) for default HTTP user
# XXX: make changeable?
system "chgaut obj('$APACHEDIR') user(qtmhhttp) dtaaut(*rwx) objaut(*all) subtree(*all)"
echo " ** Set authorities"

echo " ** You're done! Tweak the PHP and web server config as you wish."
echo "    WWW directory (htdocs, conf, logs): $APACHEDIR"
echo "    PHP config directory: $ETCPHPDIR"
echo " ** If you want to start this web server now, run the following CL command:"
echo "    STRTCPSVR SERVER(*HTTP) HTTPSVR($SITE_NAME)"
echo " ** Want to run that from a PASE shell? Use:"
echo "    system STRTCPSVR \"SERVER(*HTTP)\" \"HTTPSVR($SITE_NAME)\""
