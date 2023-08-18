#!/bin/bash

# Replace these variables with your actual values
EMAIL_TO=""
EMAIL_SUBJECT="UPS Battery Low"
SENDER_ADDRESS=""  

# Check the UPS battery percentage using the apcaccess command
battery_percentage=$(apcaccess status 2>/dev/null | awk '/BCHARGE/ {print $3}')

# Define the threshold as a floating-point number
threshold=75.0

# Compare battery percentage with the threshold using bc
if (( $(echo "$battery_percentage <= $threshold" | bc -l) )); then
    echo "UPS battery is at or below $threshold%. Sending email alert."

    # Get estimated remaining runtime
    remaining_runtime=$(apcaccess status 2>/dev/null | awk '/TIMELEFT/ {print $3}')

    # Send email using ssmtp
    {
        echo "To: $EMAIL_TO"
        echo "From: $SENDER_ADDRESS"
        echo "Subject: $EMAIL_SUBJECT"
        echo
        echo "UPS battery is at or below $threshold%."
        echo "Current Level: $battery_percentage%"
        echo "Estimated time remaining: $remaining_runtime"
    } | ssmtp -vvv $EMAIL_TO
else
    echo "UPS battery is above $threshold%. No action needed."
fi