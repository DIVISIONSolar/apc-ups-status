#!/bin/bash

DISCORD_WEBHOOK_URLS=(
    "https://discord.com/api/webhooks/"
    "https://discord.com/api/webhooks/"
    ####
    #
    # TO ADD MORE LINKS JUST DO THIS:
    # "link #1"
    # "link #2"
    # "link #3"
    #
    # AND CHANGE TO THE REAL VALUES
    #
    ####
)  

# Grab the hostname
ups_hostname=$(hostname)

# Create the webhook and stuff
create_discord_payload() {
    local battery_percentage="$1"
    local remaining_runtime="$2"

    payload='{
        "embeds": [
            {
                "title": "Power Outage Detected.",
                "description": "'"$ups_hostname"' UPS is offline. Please check the status.",
                "color": 16711680,
                "fields": [
                    {
                        "name": "Current Level",
                        "value": "'"$battery_percentage"'%",
                        "inline": true
                    },
                    {
                        "name": "Estimated Time Remaining",
                        "value": "'"$remaining_runtime"' Minutes",
                        "inline": true
                    }
                ]
            }
        ]
    }'
}

# This sends the webhook
send_discord_webhook() {
    local payload="$1"

    for webhook_url in "${DISCORD_WEBHOOK_URLS[@]}"; do
        curl -H "Content-Type: application/json" -d "$payload" "$webhook_url"
    done
}

# Check the UPS status [Don't change this! >:( ]
status=$(apcaccess status 2>/dev/null | grep STATUS | awk '{print $3}')
battery_percentage=$(apcaccess status 2>/dev/null | awk '/BCHARGE/ {print $3}')
remaining_runtime=$(apcaccess status 2>/dev/null | awk '/TIMELEFT/ {print $3}')

# Check if UPS is offline and send webhook messages if its offline
if [ "$status" != "ONLINE" ]; then
    echo "APC UPS is offline. Sending Discord webhook notifications."
    create_discord_payload "$battery_percentage" "$remaining_runtime"
    send_discord_webhook "$payload"
else
    echo "APC UPS is online."
fi