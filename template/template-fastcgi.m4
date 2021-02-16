; Static PHP servers for default user
Server type="application/x-httpd-php" CommandLine="/QOpenSys/pkgs/bin/php-cgi" SetEnv="PHPRC=xPHPDIR" SetEnv="PHP_INI_SCAN_DIR=xPHPDIR/conf.d" StartProcesses="1" SetEnv="PHP_FCGI_CHILDREN=10" SetEnv="PHP_FCGI_MAX_REQUESTS=0" ConnectionTimeout="30" RequestTimeout="60" SetEnv="LC_ALL=EN_US"

; Where to place socket files
IpcDir xWWWDIR/logs

; notes

; set US English locale to specify Unicode
; SetEnv="LC_ALL=EN_US" 
