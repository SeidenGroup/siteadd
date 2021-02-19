if rpm -q --quiet php-ibm_db2; then
	echo "ibm_db2 isn't installed. Install it with \"yum install php-ibm_db2\"."
	exit 1
fi

if rpm -q --quiet php-pdo_ibm; then
	echo "PDO_IBM isn't installed. Install it with \"yum install php-pdo_ibm\"."
	exit 1
fi

exit 0
