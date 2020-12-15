# This is the default template used for httpd.conf in siteadd.
# Provided by Seiden Group. Feel free to customize this as you wish.
# By default, this configuration is equivalent to the defaults used for a new
# site in HTTPAdmin, but with FastCGI support for PHP enabled. Some useful
# additional configuration options are commented out for further exploration.

Listen *:xPORT

# Some additional modules you can enable...
# Proxy modules:
# LoadModule proxy_module /QSYS.LIB/QHTTPSVR.LIB/QZSRCORE.SRVPGM
# LoadModule proxy_http_module /QSYS.LIB/QHTTPSVR.LIB/QZSRCORE.SRVPGM
# LoadModule proxy_connect_module /QSYS.LIB/QHTTPSVR.LIB/QZSRCORE.SRVPGM
# LoadModule proxy_ftp_module /QSYS.LIB/QHTTPSVR.LIB/QZSRCORE.SRVPGM
# SSL/TLS (HTTPS; requires further flags to enable):
# LoadModule ibm_ssl_module /QSYS.LIB/QHTTPSVR.LIB/QZSRVSSL.SRVPGM

# Transparent gzip compression (use on files that aren't already compressed, like text):
LoadModule deflate_module /QSYS.LIB/QHTTPSVR.LIB/QZSRCORE.SRVPGM
AddOutputFilterByType DEFLATE application/x-httpd-php application/json text/css application/x-javascript application/javascript text/html

# FastCGI
LoadModule zend_enabler_module /QSYS.LIB/QHTTPSVR.LIB/QZFAST.SRVPGM
AddType application/x-httpd-php .php
AddHandler fastcgi-script .php

# Set CCSID
DefaultFsCCSID 37 
CGIJobCCSID 37    

# Enable index.php to be used if no file is explicitly specified
DirectoryIndex index.php index.html

DocumentRoot xWWWDIR/htdocs
TraceEnable Off
Options -FollowSymLinks
LogFormat "%h %T %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%{Cookie}n \"%r\" %t" cookie
LogFormat "%{User-agent}i" agent
LogFormat "%{Referer}i -> %U" referer
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog logs/access_log combined
LogMaint logs/access_log 7 0
LogMaint logs/error_log 7 0
SetEnvIf "User-Agent" "Mozilla/2" nokeepalive
SetEnvIf "User-Agent" "JDK/1\.0" force-response-1.0
SetEnvIf "User-Agent" "Java/1\.0" force-response-1.0
SetEnvIf "User-Agent" "RealPlayer 4\.0" force-response-1.0
SetEnvIf "User-Agent" "MSIE 4\.0b2;" nokeepalive
SetEnvIf "User-Agent" "MSIE 4\.0b2;" force-response-1.0
<Directory />
   Require all denied
</Directory>
<Directory xWWWDIR/htdocs>
   Require all granted
</Directory>

