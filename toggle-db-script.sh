#!/usr/bin/env bash
# Toggle usage of ODBC vs. classic database extensions
# Copyright (C) 2021 Seiden Group
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
	echo "Usage: $0 [-d directory] -t (classic|odbc)"
	echo ""
	echo "Options:"
	echo "  -d directory: The conf.d directory with the INI files."
	echo "                Uses /QOpenSys/etc/php/conf.d by default."
	echo "  -t ext_type: The extension archetype to use. Either classic or odbc."
	exit 255
}

# exit_code file_type file
check_file() {
	if [ ! -f "$3" ]; then
		echo "The $2 \"$3\" doesn't exist."
		exit "$1"
	fi
}

check_dir() {
	if [ ! -d "$3" ]; then
		echo "The $2 \"$3\" doesn't exist."
		exit "$1"
	fi
}

SCANDIR="/QOpenSys/etc/php/conf.d"
EXTTYPE=""

while getopts "d:t:" o; do
	case "${o}" in
		"d")
			SCANDIR="$OPTARG"
			;;
		"t")
			case "${OPTARG}" in
			classic)
				EXTTYPE="classic"
				;;
			odbc)
				EXTTYPE="odbc"
				;;
			*)
				echo "The extension type is invalid (either odbc or classic)."
				exit 6
			esac
			;;
		*)
			echo "Unrecognized flag."
			exit 8
			;;
	esac
done
shift $((OPTIND-1))

check_dir 1 "PHP extension configuration directory" "$SCANDIR"

ODBC_INI="$SCANDIR/20-odbc.ini"
PDO_ODBC_INI="$SCANDIR/30-pdo_odbc.ini"
IBM_DB2_INI="$SCANDIR/99-ibm_db2.ini"
PDO_IBM_INI="$SCANDIR/99-pdo_ibm.ini"

check_file 2 "ODBC INI" "$ODBC_INI"
check_file 3 "PDO_ODBC INI" "$PDO_ODBC_INI"
check_file 4 "ibm_db2 INI" "$IBM_DB2_INI"
check_file 5 "PDO_IBM INI" "$PDO_IBM_INI"

# XXX: This is super hacky and could get more than what's needed (or not enough)
comment_extension() {
	sed -i 's/^\s*extension=\([A-Za-z0-9_\-\.]*\).*$/; extension=\1/g' "$1"
}

uncomment_extension() {
	sed -i 's/^\s*;\s*extension=\([A-Za-z0-9_\-\.]*\).*$/extension=\1/g' "$1"
}

case "$EXTTYPE" in
	"odbc")
		uncomment_extension "$ODBC_INI"
		uncomment_extension "$PDO_ODBC_INI"
		comment_extension "$IBM_DB2_INI"
		comment_extension "$PDO_IBM_INI"
		echo "ODBC is now enabled for $SCANDIR"
		;;
	"classic")
		comment_extension "$ODBC_INI"
		comment_extension "$PDO_ODBC_INI"
		uncomment_extension "$IBM_DB2_INI"
		uncomment_extension "$PDO_IBM_INI"
		echo "Classic database is now enabled for $SCANDIR"
		;;
	*)
		echo "The extension type isn't set (use either odbc or classic)."
		exit 7
		;;
esac
