; Static PHP servers for default user
Server type="application/x-httpd-php" CommandLine="xWWWDIR/bin/php-cgi" StartProcesses="1" SetEnv="PHP_FCGI_CHILDREN=10" SetEnv="PHP_FCGI_MAX_REQUESTS=0" ConnectionTimeout="30" RequestTimeout="60" SetEnv="LC_ALL=EN_US" SetEnv="CCSID=1208"
; Where to place socket files
IpcDir xWWWDIR/run

; notes

; Uncomment for basic auth users. This is because Apache will assume the profile of the authenticated user.
; Do not use otherwise, as it will make the socket accessible to other users.
; see https://library.roguewave.com/display/SUPPORT/Grant+IBM+i+user+profiles+permissions+to+access+PHP+when+using+Basic+Authentication
; IpcPublic *RWX

; set US English locale to specify Unicode
; see https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/apis/pase_locales.htm
; for using your own language's UTF-8 locale
; SetEnv="LC_ALL=EN_US" 

; advisory for applications
; SetEnv="CCSID=1208"
