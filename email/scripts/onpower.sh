#!/bin/bash

# Replace these variables with your actual values
EMAIL_TO=""
EMAIL_SUBJECT="Power Restored."
SENDER_ADDRESS=""

# Check the UPS status using the apcaccess command
status=$(apcaccess status 2>/dev/null | grep STATUS | awk '{print $3}')
battery_percentage=$(apcaccess status 2>/dev/null | awk '/BCHARGE/ {print $3}')
remaining_runtime=$(apcaccess status 2>/dev/null | awk '/TIMELEFT/ {print $3}')
ups_hostname=$(hostname)

# Check if UPS is online and send an email if necessary
if [ "$status" != "ONLINE" ]; then
    echo "APC UPS is online. Sending email notification."
    
    # Send email using ssmtp
    {
        echo "To: $EMAIL_TO"
        echo "From: $SENDER_ADDRESS"
        echo "Subject: $EMAIL_SUBJECT"
        echo
        echo "$ups_hostname is back online."
        echo "Current Level: $battery_percentage%"
        echo "Estimated time remaining: $remaining_runtime"
    } | ssmtp -vvv $EMAIL_TO
else
    echo "APC UPS is online."
fi