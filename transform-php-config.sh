#!/usr/bin/env bash
# Transform existing config in place
# Copyright (C) 2020-2021 Seiden Group
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
else
	. ./libsiteadd.sh --source-only
	# Use the local build
	QTIMZON2IANA=./qtimzon2iana/qtimzon2iana
fi

usage() {
	echo "Usage: $0 [-T template_directory] [-d php_ini_dir] [-P php_version]"
	echo ""
	echo "Replaces a PHP configuration with one from a template, in-place."
	echo ""
	echo "Options:"
	echo "  -d: Set the PHP INI directory. By default, the system one."
	echo "  -P: Override the PHP version for INIs. Usually auto-detected."
	echo "  -T: The template directory to use instead of the default."
	exit 255
}

ROOT_TMPL_DIR="/QOpenSys/pkgs/share/siteadd"
TMPL_DIR="/QOpenSys/pkgs/share/siteadd/template"
ETCPHPDIR="/QOpenSys/etc/php"
LOGDIR=/QOpenSys/var/log
get_installed_php_version
PHP_VERSION="$INSTALLED_PHP_VERSION"
while getopts "T:P:d:" o; do
	case "${o}" in
		"d")
			ETCPHPDIR="${OPTARG}"
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
		# XXX: Configurable target dir
		*)
			usage
			;;
	esac
done

# Dummy variables; exported for shellcheck to not complain
export APACHEDIR=/www/BOGUS
export SITE_NAME=BOGUS
export SITE_PORT=0

shift $((OPTIND-1))
# XXX: Much of this should be refactored so addsite/this share common funcs
if [[ -v TZ ]] && echo "$TZ" | grep -qs "/"; then
	TIMEZONE="$TZ"
else
	TIMEZONE=$($QTIMZON2IANA || echo "UTC")
fi
TMPL_PHPCONF="$TMPL_DIR/phpconf-$PHP_VERSION"
TMPL_PHPCONF_D="$TMPL_DIR/phpconf-$PHP_VERSION/conf.d"
# Fill in php.ini from template
m4_wrap "$TMPL_PHPCONF/php.ini.m4" "$ETCPHPDIR/php.ini"
# Copy the system config then merge the temlate configs
# This way, you can override extensions (i.e disable one),
# without having to worry about other extensions that can be left alone
cp -R "$TMPL_PHPCONF_D/"* "$ETCPHPDIR/conf.d/"
# XXX: Should we make some extension INIs m4 templates, like htdocs?
banner_msg "Changed PHP config"
