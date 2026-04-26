#!/bin/bash
set -e

# --- CONFIGURATION: MSMTP (Email) ---
if [ ! -z "$SMTP_HOST" ]; then
    echo "Configuring email settings (msmtp)..."
    cat > /etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log
account        default
host           ${SMTP_HOST}
port           ${SMTP_PORT:-587}
from           ${SMTP_FROM}
user           ${SMTP_USER}
password       ${SMTP_PASSWORD}
EOF
    chmod 600 /etc/msmtprc
else
    echo "No SMTP_HOST provided. Email reporting will be disabled."
fi

# --- RUN SPOOFER ---
LOG_FILE=/root/result.log
echo "=========================="
echo "Running the CAIDA spoofer test..."
echo "=========================="

: > $LOG_FILE
echo "Executing: $@"
"$@" > $LOG_FILE 2>&1

# --- PARSE RESULTS ---
URL_TEST_RESULT=$(grep -o 'https://spoofer.caida.org/report.php?sessionkey=[^ ]*' $LOG_FILE | tail -n 1)

# Fetch Metadata from ipwho.is
METADATA=$(curl -s --max-time 10 https://ipwho.is)
HOST_IP=$(echo "$METADATA" | jq -r '.ip // "Unknown"')
HOST_AS=$(echo "$METADATA" | jq -r '.connection.asn // "Unknown"')
HOST_ISP=$(echo "$METADATA" | jq -r '.connection.isp // "Unknown"')

IPv4_RESULT=$(grep -A 3 "IPv4 Result Summary" $LOG_FILE | sed "s/>>//" || echo "No IPv4 result found")
IPv6_RESULT=$(grep -A 5 "IPv6 Result Summary" $LOG_FILE | sed "s/>>//" || echo "No IPv6 result found")

# Get Current Date for Report
DATE_STR=$(date "+%Y-%m-%d %H:%M:%S")

RESULT_TEXT="==========================
===== TEST FINISHED! =====
==========================
DATE:         $DATE_STR
HOST_IP:      $HOST_IP
HOST_AS:      $HOST_AS
HOST_ISP:     $HOST_ISP
URL_RESULT:   $URL_TEST_RESULT

$IPv4_RESULT

$IPv6_RESULT
"

echo "$RESULT_TEXT"

# --- SEND EMAIL ---
if [ ! -z "$SMTP_HOST" ] && [ ! -z "$EMAIL_TO" ]; then
    echo "Sending email report to $EMAIL_TO..."
    
    if [ ! -z "$SMTP_DISPLAY_NAME" ]; then
        HEADER_FROM="$SMTP_DISPLAY_NAME <$SMTP_FROM>"
    else
        HEADER_FROM="$SMTP_FROM"
    fi
    
    (
        # [FIX] Added Date to Subject to break Gmail threading
        echo "Subject: CAIDA Spoofer Report - $DATE_STR"
        echo "To: $EMAIL_TO"
        echo "From: $HEADER_FROM"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/plain; charset=utf-8"
        echo ""
        echo "$RESULT_TEXT"
    ) | msmtp -t
    
    echo "Email sent."
fi

