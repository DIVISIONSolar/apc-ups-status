#!/bin/bash

# Replace these variables with your actual values
EMAIL_TO=""
EMAIL_SUBJECT="Power Outage Detected."
SENDER_ADDRESS=""

# Check the UPS status using the apcaccess command
status=$(apcaccess status 2>/dev/null | grep STATUS | awk '{print $3}')

# Check if UPS is offline and send an email if necessary
if [ "$status" != "ONLINE" ]; then
    echo "APC UPS is offline. Sending email notification."
    
    # Send email using ssmtp
    {
        echo "To: $EMAIL_TO"
        echo "From: $SENDER_ADDRESS"
        echo "Subject: $EMAIL_SUBJECT"
        echo
        echo "NA-PA-01 UPS is offline. Please check the status."
    } | ssmtp -vvv $EMAIL_TO
else
    echo "APC UPS is online."
fi