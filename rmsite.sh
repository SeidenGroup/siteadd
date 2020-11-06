#!/usr/bin/env bash
# Removes the site
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

# Only arg is site name

SITE_NAME=$1

if [ -z "$SITE_NAME" ]; then
	echo "Need a site name."
	exit 1
fi

PF_MEMBER="/QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/$SITE_NAME.MBR"
# PHP conf is under here too
APACHEDIR="/www/$SITE_NAME/"

if [ ! -d "$APACHEDIR" ]; then
	echo "The site doesn't exist."
	exit 2
fi

echo " ** Ending..."
system ENDTCPSVR "SERVER(*HTTP)" "HTTPSVR($SITE_NAME)"

echo " ** Deleting..."

rm "$PF_MEMBER"
rm -rf "$APACHEDIR"
echo " ** Done."
