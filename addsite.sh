#!/usr/bin/env bash
# Create HTTP server and populate PHP config for it
# Copyright (C) 2020-2024 Seiden Group
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

if [ -x /QOpenSys/pkgs/lib/siteadd/libsiteadd.sh ]; then
	. /QOpenSys/pkgs/lib/siteadd/libsiteadd.sh --source-only
	# Since it's installed, assume it's on PATH
	QTIMZON2IANA=qtimzon2iana
	CANLISTEN=canlisten
else
	. ./libsiteadd.sh --source-only
	# Use the local build
	QTIMZON2IANA=./qtimzon2iana/qtimzon2iana
	CANLISTEN=./canlisten.php
fi

usage() {
	echo "Usage: $0 -p port -n site_name [-C old_site] [-T template_directory] [-I|-i] [-f] [-Y|-N] [-P php_version] [-c chroot_path] [-A addr]"
	echo ""
	echo "Creates a site from a template."
	echo ""
	echo "Simplest usage: $0 -p port -n site_name"
	echo ""
	echo "Options:"
	echo "  -p port: Set the port number for the web site."
	echo "           This must be unique."
	echo "  -n name: The name of the site. This must be ten characters"
	echo "           or less, and meet the traditional naming rules for"
	echo "           for IBM i physical file members."
	echo "  -I: Make a separate directory for PHP INI files. Default."
	echo "      PHP INIs will then be in /www/sitename/phpconf."
	echo "      Said INIs will be copied from the template directory."
	echo "      The PHP extension configuration will be the system-wide"
	echo "      configuration with template-specific configuration."
	echo "      The default otherwise is to use the shared PHP etc dir."
	echo "  -i: Use the global configuration directory instead."
	echo "  -P: Override the PHP version for INIs. Usually auto-detected."
	echo "  -c chroot: Prefix to use for a chroot. Note that the chroot"
	echo "      path is only used as a prefix and not actually chrooted,"
	echo "      due to ILE Apache limitations."
	echo "  -C: Copy htdocs from another site. Must exist."
	echo "  -Y: If the site should start automatically. Default."
	echo "  -N: If the site should not start automatically."
	echo "  -T: The template directory to use instead of the default."
	echo "  -A: The IP address to bind to. Wildcard by default."
	exit 255
}

MAKE_ETCPHP=yes
AUTOSTART=" -AutoStartY"
ROOT_TMPL_DIR="/QOpenSys/pkgs/share/siteadd"
TMPL_DIR="/QOpenSys/pkgs/share/siteadd/template"
OLD_SITENAME=""
CHROOT_PREFIX=""
FORCE_PORT=no
FORCE_PHP_VERSION=""
BIND_ADDRESS="*"
# overridden as needed
EXECUTABLE=""

# before anything could use i.e. M4
check_packages

while getopts ":p:n:T:C:c:YNfIiP:A:" o; do
	case "${o}" in
		"p")
			SITE_PORT=${OPTARG}
			if ! [[ "$SITE_PORT" =~ ^[0-9]*$ ]] ; then
				error_msg "The site port isn't a number."
				exit 6
			fi
			# above regex forces positive integer, so negative can't happen
			if [ "$SITE_PORT" -gt 65535 ]; then
				# max port number
				error_msg "The site port is greater than 65535."
				exit 7
			fi
			;;
		"f")
			# While we can not use the port if it's already being
			# listened on by something, we give users the choice to
			# do so anyways, in case it's just for show or if they
			# would make the changes afterwards.
			FORCE_PORT=yes
			;;
		"n")
			SITE_NAME=${OPTARG}
			if [ -z "${#SITE_NAME}" ]; then
				error_msg "The site name is empty."
				exit 8
			fi
			# XXX: What limitations does HTTPA have on names?
			if [ "${#SITE_NAME}" -gt 10 ]; then
				error_msg "The site name is longer than 10 characters."
				exit 9
			fi
			;;
		"P")
			# Filter out only supported versions of PHP
			case "${OPTARG}" in
			7.3)
				FORCE_PHP_VERSION=7.3
				;;
			7.4)
				FORCE_PHP_VERSION=7.4
				;;
			8.0)
				FORCE_PHP_VERSION=8.0
				;;
			8.1)
				FORCE_PHP_VERSION=8.1
				;;
			8.2)
				FORCE_PHP_VERSION=8.2
				;;
			8.3)
				FORCE_PHP_VERSION=8.3
				;;
			8.4)
				FORCE_PHP_VERSION=8.4
				;;
			*)
				error_msg "The PHP version is invalid."
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
		"c")
			CHROOT_PREFIX=${OPTARG}
			;;
		"A")
			# XXX: Validate IPv4/6 address (regex?)
			BIND_ADDRESS=${OPTARG}
			;;
		"I")
			MAKE_ETCPHP=yes
			;;
		"i")
			MAKE_ETCPHP=no
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

# Check after getopt in case we're peeking inside of a chroot
get_installed_php_version
if [ -n "$FORCE_PHP_VERSION" ]; then
	PHP_VERSION="$FORCE_PHP_VERSION"
else
	PHP_VERSION="$INSTALLED_PHP_VERSION"
fi

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
TMPL_BIN="$TMPL_DIR/template-wrapper.m4"
TMPL_PHPCONF="$TMPL_DIR/phpconf-$PHP_VERSION"
TMPL_PHPCONF_D="$TMPL_DIR/phpconf-$PHP_VERSION/conf.d"
TMPL_HTDOCS="$TMPL_DIR/htdocs"
TMPL_HTDOCS_T="$TMPL_DIR/htdocs-templates"

check_file 4 "httpd.conf template" "$TMPL_HTTP"
check_file 5 "fastcgi.conf template" "$TMPL_FCGI"
check_dir 16 "PHP extension configuration template" "$TMPL_PHPCONF_D"
# this used to be a check for phpconf dir itself, but if conf.d succeeded...
check_file 15 "PHP configuration template" "$TMPL_PHPCONF/php.ini.m4"
check_file 13 "list of page templates" "$TMPL_HTDOCS_T"
check_dir 11 "directory of page templates" "$TMPL_HTDOCS"
if [ -n "$CHROOT_PREFIX" ]; then
	check_dir 20 "chroot prefix" "$CHROOT_PREFIX"
fi

if [ -n "$OLD_SITENAME" ] && [ ! -d "/www/$OLD_SITENAME/htdocs" ]; then
	error_msg "The old site doesn't exist."
	exit 12
fi

if [ "$(uname)" != "OS400" ]; then
	error_msg "Hey, this isn't i!"
	exit 10
fi

# If the preflight check exists, run it
PREFLIGHT="$TMPL_DIR/preflight.sh"
if [ -f "$PREFLIGHT" ]; then
	if ! "$PREFLIGHT"; then
		error_msg "The preflight check failed (exit code $?)"
		exit 17
	fi
fi

if [ "$FORCE_PORT" = "no" ] && ! $CANLISTEN "$SITE_PORT"; then
	error_msg "The port is already being listened on; use -f to use this port anyways."
	exit 19
fi

if [ "$MAKE_ETCPHP" = "no" ] && [ -n "$CHROOT_PREFIX" ]; then
	error_msg "Can't use a chroot prefix without making a site-specific config."
	exit 21
fi

banner_msg "Validity checks finished"

# XXX: Should we also set TZ in the FastCGI config?
set_timezone_var
set_ccsid_var

PF_MEMBER="/QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/$SITE_NAME.MBR"
# slashes are appended as needed
APACHEDIR="/www/$SITE_NAME"
if [ "$MAKE_ETCPHP" = "yes" ]; then
	ETCPHPDIR="$APACHEDIR/phpconf"
else
	ETCPHPDIR="$CHROOT_PREFIX/QOpenSys/etc/php"
fi
LOGDIR="$APACHEDIR/logs"
ETCPHPCONFDDIR="$ETCPHPDIR/conf.d"

# these are case-insensitive... very much so
if [ -e "$PF_MEMBER" ]; then
	error_msg "The site already is in the physical file."
	exit 1
fi

if [ -d "$APACHEDIR" ]; then
	error_msg "The site already has the IFS WWW directory."
	exit 2
fi

# XXX: Is this the convention we want to rely on?
if [ -d "$ETCPHPDIR" ] && [ "$MAKE_ETCPHP" = "yes" ]; then
	error_msg "The site already has the IFS PHP directory."
	exit 3
fi
banner_msg "Verified existing config"

# Create entries 
system "addpfm file(qusrsys/qatmhinstc) mbr($SITE_NAME)"
Rfile -w "$PF_MEMBER" << EOF
-apache -d /www/$SITE_NAME -f conf/httpd.conf$AUTOSTART
EOF
banner_msg "Added PFM for HTTPd"

# Create /www directory
for dir in {bin,logs,run,conf,htdocs}; do
	mkdir -p "$APACHEDIR/$dir"
done
banner_msg "Made directories for web server"

EXECUTABLE="php" m4_wrap "$TMPL_BIN" "$APACHEDIR/bin/php"
EXECUTABLE="php-cgi" m4_wrap "$TMPL_BIN" "$APACHEDIR/bin/php-cgi"
banner_msg "Made wrapper executables"

if [ -n "$OLD_SITENAME" ]; then
	cp -R "/www/$OLD_SITENAME/htdocs/"* "$APACHEDIR/htdocs/"
	banner_msg "Copied old site documents"
fi

m4_wrap "$TMPL_HTTP" "$APACHEDIR/conf/httpd.conf"
m4_wrap "$TMPL_FCGI" "$APACHEDIR/conf/fastcgi.conf"
if [ -z "$OLD_SITENAME" ]; then
	cp -R "$TMPL_HTDOCS/"* "$APACHEDIR/htdocs/"
	banner_msg "Copied new site template"
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
banner_msg "Filled in templates"

if [ "$MAKE_ETCPHP" = "yes" ]; then
	mkdir "$ETCPHPDIR"
	# Fill in php.ini from template
	m4_wrap "$TMPL_PHPCONF/php.ini.m4" "$ETCPHPDIR/php.ini"
	# Copy the system config then merge the temlate configs
	# This way, you can override extensions (i.e disable one),
	# without having to worry about other extensions that can be left alone
	mkdir "$ETCPHPCONFDDIR/"
	cp -R "$CHROOT_PREFIX/QOpenSys/etc/php/conf.d/"* "$ETCPHPCONFDDIR/"
	cp -R "$TMPL_PHPCONF_D/"* "$ETCPHPCONFDDIR/"
	# XXX: Should we make some extension INIs m4 templates, like htdocs?
	banner_msg "Made configuration for PHP"
fi

# Set authorities (can't set ACLs from PASE) for default HTTP user
# XXX: make changeable?
# Note that the group owner of the socket directory must NOT be set;
# this doesn't seem documented.
chgrp -R 0 "$APACHEDIR"
system "chgaut obj('$APACHEDIR') user(qtmhhttp) dtaaut(*rwx) objaut(*all) subtree(*all)"
banner_msg "Set authorities"

# Final step: If the postflight check exists, run it
POSTFLIGHT="$TMPL_DIR/postflight.sh"
if [ -f "$POSTFLIGHT" ]; then
	if ! "$POSTFLIGHT"; then
		error_msg "The postflight check failed (exit code $?)"
		exit 18
	fi
fi

banner_msg "You're done! Tweak the PHP and web server config as you wish."
indent_msg "WWW directory (htdocs, conf, logs): $APACHEDIR"
indent_msg "PHP config directory: $ETCPHPDIR"
indent_msg "PHP extension config directory: $ETCPHPCONFDDIR"
# XXX: This assumes the hostname is set. It's the easiest method we can assume
# because snarfing the hostname and default IP address is more effort. Priority
# when it becomes a problem.
indent_msg "URL: http://$(hostname):$SITE_PORT"
banner_msg "If you want to start this web server now, run the following CL command:"
indent_msg "STRTCPSVR SERVER(*HTTP) HTTPSVR($SITE_NAME)"
banner_msg "Want to run that from a PASE shell? Use:"
indent_msg "system STRTCPSVR \"SERVER(*HTTP)\" \"HTTPSVR($SITE_NAME)\""
# Only relevant if Service Commander is installed
if [ -x "/QOpenSys/pkgs/bin/sc_install_defaults" ]; then
	banner_msg "Want to use Service Commander for this and other Apache instances:"
	indent_msg "/QOpenSys/pkgs/bin/sc_install_defaults --apache"
	banner_msg "Want to see which instances are registered with Service Commander?"
	indent_msg "/QOpenSys/pkgs/bin/sc list group:apache"
fi
# Only relevant with custom PHP config for site
if [ "$MAKE_ETCPHP" = "yes" ]; then
	banner_msg "Want to run PHP CLI programs with your server's configuration? Use the shell command:"
	indent_msg "PHPRC=\"$ETCPHPDIR\" PHP_INI_SCAN_DIR=\"$ETCPHPCONFDDIR\" $CHROOT_PREFIX/QOpenSys/pkgs/bin/php"
fi
