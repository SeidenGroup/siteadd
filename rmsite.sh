#!/usr/bin/env bash
# Removes the site

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

echo " ** Deleting..."

rm "$PF_MEMBER"
rm -rf "$APACHEDIR"
echo " ** Done."
