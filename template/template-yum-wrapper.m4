#!/QOpenSys/pkgs/bin/bash
# This script wraps yum with the right settings for your chroot and PHP version.

PHPVER="xPHPVER"
CHROOTPREFIX="xCHROOTPREFIX"

# If a repo doesn't exist, then using enable/disablerepo will cause yum to bail.
# We need to check if it exists and build up a set of parameters.
REPOARGS=""
for repo in $(yum repolist all | col | cut -f 1); do
	case "$repo" in
	seiden_stable_*)
		;;
	*)
		continue
		;;
	esac
	# Extract the version and format it the same way as PHPVER
	just_numeric=$(echo "$repo" | tr -d -c 0-9)
	REPO_PHPVER="${just_numeric:0:1}.${just_numeric:1:1}"
	if [ "$REPO_PHPVER" = "$PHPVER" ]; then
		REPOARGS="$REPOARGS --enablerepo=$repo"
	else
		REPOARGS="$REPOARGS --disablerepo=$repo"
	fi
done

exec yum \
	--installroot="$CHROOTPREFIX" \
	$REPOARGS \ 
	$*
