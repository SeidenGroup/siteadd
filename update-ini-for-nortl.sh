#!/usr/bin/env bash
# Toggle usage of ODBC vs. classic database extensions
# Copyright (C) 2024 Seiden Group
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
else
	. ./libsiteadd.sh --source-only
fi

# before anything could use i.e. M4
check_packages

usage() {
	echo "Usage: [sitename1] [sitename2] [...]"
	echo ""
	echo "Note that for the global extension configuration (in /QOpenSys/etc/php/conf.d),"
	echo "RPM will automatically clean these references up unless you have changed them."
	exit 255
}

if [ $# -lt 1 ]; then
	usage
fi

for site in "$@"; do
	# XXX: Check fastcgi.conf first, handle ASPs
	PHP_INI_SCAN_DIR="/www/$site/phpconf/conf.d"

	if ! [ -d "$PHP_INI_SCAN_DIR" ]; then
		banner_msg "The extension INI directory for $site doesn't exist, continuing"
		continue
	fi
	
	# Disable the extensions that are now built into the PHP binary.
	comment_extension "$PHP_INI_SCAN_DIR/20-dom.ini"
	comment_extension "$PHP_INI_SCAN_DIR/20-mysqlnd.ini"
	comment_extension "$PHP_INI_SCAN_DIR/20-pdo.ini"
	banner_msg "Done fixing up extension INIs for site $site"
done
