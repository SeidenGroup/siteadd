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
	echo "Usage: $0 -p port -n site_name [-C old_site] [-T template_directory] [-I] [-Y|-N]"
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
	echo "      Said INIs will be copied from the template directory."
	echo "      The PHP extension configuration will be the system-wide"
	echo "      configuration with template-specific configuration."
	echo "      The default otherwise is to use the shared PHP etc dir."
	echo "  -P: Override the PHP version for INIs. Usually auto-detected."
	echo "  -C: Copy htdocs from another site. Must exist."
	echo "  -Y: If the site should start automatically. Default."
	echo "  -N: If the site should not start automatically."
	echo "  -T: The template directory to use instead of the default."
	exit 255
}

m4_wrap() {
	# without -P, it's easy to trip up m4 on PHP INIs (refs to builtins)
	m4 -P -D "xSITE_NAME=$SITE_NAME" -D "xPHPDIR=$ETCPHPDIR" -D "xWWWDIR=$APACHEDIR" -D "xPORT=$SITE_PORT" "$1" > "$2"
}

MAKE_ETCPHP=no
AUTOSTART=" -AutoStartY"
ROOT_TMPL_DIR="/QOpenSys/pkgs/share/siteadd"
TMPL_DIR="/QOpenSys/pkgs/share/siteadd/template"
OLD_SITENAME=""

INSTALLED_PHP_VERSION=$(rpm -q --queryformat "%{VERSION}" php-common | sed -E 's/([0-9]+)\.([0-9]+)\..*/\1.\2/g')
PHP_VERSION="$INSTALLED_PHP_VERSION"

while getopts ":p:n:T:C:YNI" o; do
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
		"P")
			# Filter out only supported versions of PHP
			case "${OPTARG}" in
			7.3)
				PHP_VERSION=7.3
				;;
			7.4)
				PHP_VERSION=7.4
				;;
			8.0)
				PHP_VERSION=8.0
				;;
			*)
				echo "The PHP version is invalid."
				exit 14
			esac
			;;
		"T")
			# if it has a / then it's a path, otherwise look in template dir
			case "${OPTARG}" in
			*/*)
				TMPL_DIR=${OPTARG}
				;;
			*)
				TMPL_DIR="$ROOT_TMPL_DIR/${OPTARG}"
				;;
			esac
			;;
		"C")
			OLD_SITENAME=${OPTARG}
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

TMPL_HTTP="$TMPL_DIR/template-httpd.m4"
TMPL_FCGI="$TMPL_DIR/template-fastcgi.m4"
TMPL_PHPCONF="$TMPL_DIR/phpconf-$PHP_VERSION"
TMPL_PHPCONF_D="$TMPL_DIR/phpconf-$PHP_VERSION/conf.d"
TMPL_HTDOCS="$TMPL_DIR/htdocs"
TMPL_HTDOCS_T="$TMPL_DIR/htdocs-templates"
if [ ! -f "$TMPL_HTTP" ]; then
	echo "The HTTPd template \"$TMPL_HTTP\" doesn't exist."
	exit 4
fi
if [ ! -f "$TMPL_FCGI" ]; then
	echo "The FastCGI template \"$TMPL_FCGI\" doesn't exist."
	exit 5
fi
if [ ! -d "$TMPL_PHPCONF_D" ]; then
	echo "The PHP extension configuration template \"$TMPL_PHPCONF_D\" doesn't exist."
	exit 16
fi
if [ ! -d "$TMPL_PHPCONF" ]; then
	echo "The PHP configuration template \"$TMPL_PHPCONF\" doesn't exist."
	exit 15
fi
if [ ! -f "$TMPL_HTDOCS_T" ]; then
	echo "The list of page templates \"$TMPL_HTDOCS_T\" doesn't exist."
	exit 
fi
if [ ! -d "$TMPL_HTDOCS" ]; then
	echo "The directory of page templates \"$TMPL_HTDOCS\" doesn't exist."
	exit 11
fi

if [ -n "$OLD_SITENAME" ] && [ ! -d "/www/$OLD_SITENAME/htdocs" ]; then
	echo "The old site doesn't exist."
	exit 12
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

if [ -n "$OLD_SITENAME" ]; then
	cp -R "/www/$OLD_SITENAME/htdocs/"* "$APACHEDIR/htdocs/"
	echo " ** Copied old site documents"
fi

m4_wrap "$TMPL_HTTP" "$APACHEDIR/conf/httpd.conf"
m4_wrap "$TMPL_FCGI" "$APACHEDIR/conf/fastcgi.conf"
if [ -z "$OLD_SITENAME" ]; then
	cp -R "$TMPL_HTDOCS/"* "$APACHEDIR/htdocs/"
	echo " ** Copied new site template"
	# don't generate this if we have an existing site to copy htdocs from
	# each file in the htdocs-template file has an m4 template to create it
	while read -r html_template; do
		absolute_html_template="$TMPL_HTDOCS/$html_template.m4"
		if [ -f "$absolute_html_template" ]; then
			m4_wrap "$absolute_html_template" "$APACHEDIR/htdocs/$html_template"
			# we no longer need the m4 template
			rm "$APACHEDIR/htdocs/$html_template.m4"
		fi
	done < "$TMPL_HTDOCS_T"
fi
echo " ** Filled in templates"

if [ "$MAKE_ETCPHP" = "yes" ]; then
	mkdir "$ETCPHPDIR"
	# Fill in php.ini from template
	m4_wrap "$TMPL_PHPCONF/php.ini.m4" "$ETCPHPDIR/php.ini"
	# Copy the system config then merge the temlate configs
	# This way, you can override extensions (i.e disable one),
	# without having to worry about other extensions that can be left alone
	cp -R "/QOpenSys/etc/php/conf.d" "$ETCPHPDIR/conf.d"
	cp -R "$TMPL_PHPCONF_D" "$ETCPHPDIR/conf.d"
	# XXX: Should we make some extension INIs m4 templates, like htdocs?
	echo " ** Made copnfiguration for PHP"
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
