#!/usr/bin/env bash
# siteadd library functions
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

banner_msg() {
	echo " ** $1"
}

indent_msg() {
	echo "    $1"
}

error_msg() {
	echo "$1" 1>&2
}

m4_wrap() {
	# without -P, it's easy to trip up m4 on PHP INIs (refs to builtins)
	m4 -P -D "xSITE_NAME=$SITE_NAME" -D "xPHPDIR=$ETCPHPDIR" -D "xWWWDIR=$APACHEDIR" -D "xPORT=$SITE_PORT" "$1" > "$2"
}

# exit_code file_type file
check_file() {
	if [ ! -f "$3" ]; then
		error_msg "The $2 \"$3\" doesn't exist."
		exit "$1"
	fi
}

check_dir() {
	if [ ! -d "$3" ]; then
		error_msg "The $2 \"$3\" doesn't exist."
		exit "$1"
	fi
}

# XXX: This is super hacky and could get more than what's needed (or not enough)
comment_extension() {
	sed -i 's/^\s*extension=\([A-Za-z0-9_\-\.]*\).*$/; extension=\1/g' "$1"
}

uncomment_extension() {
	sed -i 's/^\s*;\s*extension=\([A-Za-z0-9_\-\.]*\).*$/extension=\1/g' "$1"
}