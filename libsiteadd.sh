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
	m4 -P -D "xSITE_NAME=$SITE_NAME" -D "xPHPDIR=$ETCPHPDIR" -D "xWWWDIR=$APACHEDIR" -D "xLOGDIR=$LOGDIR" -D "xPORT=$SITE_PORT" -D "xTIMEZONE=$TIMEZONE" -D "xCCSID=$CCSID" -D "xCHROOTPREFIX=$CHROOT_PREFIX" -D "xPHPVER=$PHP_VERSION" "$1" > "$2"
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

# Gets the installed PHP version as a global variable
get_installed_php_version() {
	local USE_PREFIX="$CHROOT_PREFIX"
	if [ -z "$USE_PREFIX" ]; then
		USE_PREFIX=/
	fi
	export INSTALLED_PHP_VERSION=$(rpm --root="$USE_PREFIX" -q --queryformat "%{VERSION}" php-common | sed -E 's/([0-9]+)\.([0-9]+)\..*/\1.\2/g')
	# XXX: Error out if PHP not installed
}

# Gather the timezone, since TZ is set NOT the IANA values under PASE
# (at least by default); we have a program to gather the current *TIMZON
# and the IANA name associated with it. PHP has its own built-in TZ DB.
# If TZ is already set as an IANA value, use it.
# Sets the timezone in a global. Assumes vars for TZ or TZ tool are set.
set_timezone_var() {
	if [[ -v TZ ]] && echo "$TZ" | grep -qs "/"; then
		export TIMEZONE="$TZ"
	else
		export TIMEZONE=$($QTIMZON2IANA || echo "UTC")
	fi
}

set_ccsid_var() {
	if [[ -v CCSID ]] && echo "$CCSID" | grep -qsE "[0-9]+"; then
		# nop if user already sets it
		true
	else
		# Get the current job CCSID (in process).
		# DFTCCSID is used because CCSID can be 65535 (bad)
		# Not sure about the cut point. cl/system will strip end WS
		CCSID=$(cl dspjob | grep DFTCCSID | cut -b 66-)
	fi
	banner_msg "The selected CCSID is $CCSID"
}

# XXX: This is super hacky and could get more than what's needed (or not enough)
comment_extension() {
	sed -i 's/^\s*extension=\([A-Za-z0-9_\-\.]*\).*$/; extension=\1/g' "$1"
}

uncomment_extension() {
	sed -i 's/^\s*;\s*extension=\([A-Za-z0-9_\-\.]*\).*$/extension=\1/g' "$1"
}
