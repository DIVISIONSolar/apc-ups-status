#!/bin/bash

# Replace these variables with your actual values
EMAIL_TO=""
EMAIL_SUBJECT="UPS Battery Critically Low"
SENDER_ADDRESS=""
TIMESTAMP_FILE="/tmp/last_email_sent_timestamp_critically_low"

# Check the UPS battery percentage using the apcaccess command
battery_percentage=$(apcaccess status 2>/dev/null | awk '/BCHARGE/ {print $3}')

# Define the threshold as a floating-point number
threshold=30.0

# Get the current timestamp
current_timestamp=$(date +%s)

# Read the last email sent timestamp from the file (if it exists)
if [ -f "$TIMESTAMP_FILE" ]; then
    last_email_timestamp=$(cat "$TIMESTAMP_FILE")
else
    last_email_timestamp=0
fi

# Calculate the time elapsed since the last email
time_elapsed=$((current_timestamp - last_email_timestamp))

# Compare battery percentage with the threshold using bc
if (( $(echo "$battery_percentage <= $threshold" | bc -l) )) && [ "$time_elapsed" -ge 1800 ]; then
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

    # Update the last email sent timestamp
    echo "$current_timestamp" > "$TIMESTAMP_FILE"
else
    echo "UPS battery is above $threshold% or email was sent recently. No action needed."
fi
