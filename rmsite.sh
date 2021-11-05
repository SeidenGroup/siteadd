#!/usr/bin/env bash
# Removes the site
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
else
	. ./libsiteadd.sh --source-only
fi

usage() {
	echo "Usage: $0 [-r] site_name"
	echo ""
	echo "Removes a site entry, and optionally deletes its files."
	echo ""
	echo "Options:"
	echo "  -r: Delete the files too."
	exit 255
}

DELETE_FILES=no
while getopts "r" o; do
	case "${o}" in
		"r")
			DELETE_FILES=yes
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

SITE_NAME=$1

if [ -z "$SITE_NAME" ]; then
	error_msg "Need a site name."
	exit 1
fi

PF_MEMBER="/QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/$SITE_NAME.MBR"
# PHP conf is under here too
APACHEDIR="/www/$SITE_NAME/"

# Maybe check for PFM too, but could break -r
if [ ! -d "$APACHEDIR" ]; then
	error_msg "The site doesn't exist."
	exit 2
fi

banner_msg "Ending..."
# this is || true in case the server isn't running already
system ENDTCPSVR "SERVER(*HTTP)" "HTTPSVR($SITE_NAME)" || true

banner_msg "Deleting member..."

rm "$PF_MEMBER"
if [ "$DELETE_FILES" = "yes" ]; then
	banner_msg "Deleting files..."
	rm -rf "$APACHEDIR"
fi
banner_msg "Done."
