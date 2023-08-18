#!/bin/bash

# Replace these variables with your actual values
DISCORD_WEBHOOK_URL=""

# Function to send a Discord webhook message
send_discord_webhook() {
    local messages=("$@")
    local message_data=""
    
    for message in "${messages[@]}"; do
        message_data+="[$message] \n"
    done
    
    curl -X POST -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"APC UPS Alert\",\"description\":\"$message_data\",\"color\":16711680}]}" $DISCORD_WEBHOOK_URL
}

# Check the UPS status using the apcaccess command
status=$(apcaccess status 2>/dev/null | grep STATUS | awk '{print $3}')

# Check if UPS is offline and send a single Discord webhook message if necessary
if [ "$status" != "ONLINE" ]; then
    echo "APC UPS is offline. Sending Discord webhook notification."

    # Send a single webhook message with multiple lines
    send_discord_webhook \
        "Power Outage Detected." \
        "NA-PA-01 UPS is offline. Please check the status."
else
    echo "APC UPS is online."
fi
