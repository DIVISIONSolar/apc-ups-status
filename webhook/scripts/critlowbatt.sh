#!/bin/bash

# Replace this with your actual Discord webhook URL
DISCORD_WEBHOOK_URL="YOUR_DISCORD_WEBHOOK_URL"

# Replace these variables with your actual values
TIMESTAMP_FILE="/tmp/last_message_sent_timestamp_critically_low"

# Check the UPS battery percentage using the apcaccess command
battery_percentage=$(apcaccess status 2>/dev/null | awk '/BCHARGE/ {print $3}')

# Define the threshold as a floating-point number
threshold=30.0

# Get the current timestamp
current_timestamp=$(date +%s)

# Read the last message sent timestamp from the file (if it exists)
if [ -f "$TIMESTAMP_FILE" ]; then
    last_message_timestamp=$(cat "$TIMESTAMP_FILE")
else
    last_message_timestamp=0
fi

# Calculate the time elapsed since the last message
time_elapsed=$((current_timestamp - last_message_timestamp))

# Compare battery percentage with the threshold using bc
if (( $(echo "$battery_percentage <= $threshold" | bc -l) )) && [ "$time_elapsed" -ge 1800 ]; then
    echo "UPS battery is at or below $threshold%. Sending message to Discord."

    # Get estimated remaining runtime
    remaining_runtime=$(apcaccess status 2>/dev/null | awk '/TIMELEFT/ {print $3}')

    # Prepare the JSON payload for the embedded message in Discord
    discord_payload='{
        "embeds": [
            {
                "title": "Critical UPS Battery Alert",
                "description": "UPS battery is critically low at or below '"$threshold"'%",
                "color": 16711680,
                "fields": [
                    {
                        "name": "Current Level",
                        "value": "'"$battery_percentage"'%",
                        "inline": true
                    },
                    {
                        "name": "Estimated Time Remaining",
                        "value": "'"$remaining_runtime"'",
                        "inline": true
                    }
                ]
            }
        ]
    }'

    # Send embedded message to Discord using curl
    curl -H "Content-Type: application/json" -d "$discord_payload" "$DISCORD_WEBHOOK_URL"

    # Update the last message sent timestamp
    echo "$current_timestamp" > "$TIMESTAMP_FILE"
else
    echo "UPS battery is above $threshold% or message was sent recently. No action needed."
fi
