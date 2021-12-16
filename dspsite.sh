#!/usr/bin/env bash
# Display site information
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

# before anything could use i.e. M4
check_packages

usage() {
	echo "Usage: $0 site_name"
	echo ""
	echo "Displays site information."
	exit 255
}

while getopts "" o; do
	case "${o}" in
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ "$#" -lt "1" ]; then
	error_msg "Need a site name."
	exit 1
fi
SITE_NAME=$1

PF_MEMBER="/QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/$SITE_NAME.MBR"
# PHP conf is under here too. do not add a trailing slash for dspsite
APACHEDIR="/www/$SITE_NAME"

# XXX: Simplistic, doesn't check for modifications against the grain 
if [ ! -d "$APACHEDIR" ]; then
	error_msg "The site doesn't exist."
	exit 2
fi

echo "Physical file: $PF_MEMBER"
Rfile -r "$PF_MEMBER"

echo

echo "Site directory (logs, htdocs, conf): $APACHEDIR"
LOGFILE="/QOpenSys/var/log/php_error.log"
CONFDIR="/QOpenSys/etc/php"
CONFTYPE="global"
if [ -d "$APACHEDIR/phpconf" ]; then
	CONFDIR="$APACHEDIR/phpconf"
	LOGFILE="$APACHEDIR/logs/php_error.log"
	CONFTYPE="site-specific"
fi
echo "Log file ($CONFTYPE): $LOGFILE"
echo "PHP config dir (i.e. php.ini) ($CONFTYPE): $CONFDIR"
