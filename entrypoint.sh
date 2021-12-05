#!/bin/bash

LOG_FILE=/root/result.log

echo "=========================="
echo "Running the CAIDA spoofer test..."
echo "=========================="

# Create test results log file
touch $LOG_FILE

# Run spoofer
spoofer-prober -s1 -r1 > $LOG_FILE

# Parse results
URL_TEST_RESULT=$(tail -n 50 $LOG_FILE | grep 'https://spoofer.caida.org/report.php?sessionkey=' | tr -d ' ')
HOST_IP=$(curl -s https://ifconfig.me/ip)
whois_result=$(whois -h whois.cymru.com ${HOST_IP} | sed -n 2p)
HOST_AS=$(echo $whois_result | cut -d'|' -f 1)
HOST_ISP=$(echo $whois_result | cut -d'|' -f 3)

# Print results
echo "=========================="
echo "===== TEST FINISHED! ====="
echo "=========================="
result="HOST_IP:      $HOST_IP\n"
result+="HOST_AS:      $HOST_AS\n"
result+="HOST_ISP:     $HOST_ISP\n"
result+="URL_RESULT:   $URL_TEST_RESULT\n"
echo -ne $result

if [ ! - z "$EMAILADDRESS" ]
then 
	# Send results
	echo "=========================="
	echo "Sending results..."
	echo "=========================="
	email="Subject: CAIDA Spoofer test excuted\n"
	email+="To: $EMAILADDRESS\n\n"
	email+="$result"
	echo -ne $email | ssmtp -t
fi
