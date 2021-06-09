#!/usr/bin/env bash
# Toggle site's "startiness"
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

if [ -x /QOpenSys/pkgs/lib/siteadd/libsiteadd.sh ]; then
	. /QOpenSys/pkgs/lib/siteadd/libsiteadd.sh --source-only
else
	. ./libsiteadd.sh --source-only
fi

usage() {
	echo "Usage: $0 [-n sitename] [-Y] [-N]"
	echo ""
	echo "Options:"
	echo "  -n sitename: The name of the site to change."
	echo "  -Y:          Make the site start on IPL."
	echo "  -N:          Don't make the site start on IPL."
	echo ""
	echo "If no options are given, it will display the autostart value."
	exit 255
}

SITE_NAME=""
TOGGLE_MODE="display"

while getopts "n:YN" o; do
	case "${o}" in
		"n")
			SITE_NAME="$OPTARG"
			;;
		"Y")
			TOGGLE_MODE="enable"
			;;
		"N")
			TOGGLE_MODE="disable"
			;;
		*)
			error_msg "Unrecognized flag."
			exit 8
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "$SITE_NAME" ]; then
	banner_msg "The site name wasn't provided."
	exit 2
fi

PF_MEMBER="/QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/$SITE_NAME.MBR"

case "$TOGGLE_MODE" in
	"display")
		if Rfile -r "$PF_MEMBER" | grep -- "-AutoStartY"; then
			echo "autostarting"
		else
			echo "not autostarting"
		fi
		;;
	"enable")
		Rfile -r "$PF_MEMBER" | sed 's/-AutoStartN/-AutoStartY/g' | Rfile -w "$PF_MEMBER"
		banner "Site now autostarts"
		;;
	"disable")
		Rfile -r "$PF_MEMBER" | sed 's/-AutoStartY/-AutoStartN/g' | Rfile -w "$PF_MEMBER"
		banner "Site won't autostart"
		;;
	*)
		error_msg "The mode isn't set."
		exit 1
		;;
esac
