#!/QOpenSys/usr/bin/sh
# This script runs PHP with the INI for the site, and sets any additional variables.

PHPRC=xPHPDIR
PHP_INI_SCAN_DIR=xPHPDIR/conf.d
export PHPRC PHP_INI_SCAN_DIR
# Set LIBPATH here if using a chroot
m4_ifelse(xCHROOTPREFIX, `', `', `LIBPATH=xCHROOTPREFIX/QOpenSys/pkgs/lib:xCHROOTPREFIX/QOpenSys/usr/lib:/QOpenSys/pkgs/lib:/QOpenSys/usr/lib')
m4_ifelse(xCHROOTPREFIX, `', `', `export LIBPATH')

exec xCHROOTPREFIX/QOpenSys/pkgs/bin/xEXECUTABLE
