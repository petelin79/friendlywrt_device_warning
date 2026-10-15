#!/bin/sh

# Telegram configuration
TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"
KNOWN_FILE="/etc/known_macs"


# Process new DHCP leases only
[ "$ACTION" = "add" ] || exit 0

[ -n "$MACADDR" ] || exit 0
[ -n "$IPADDR" ] || exit 0

HOST="${HOSTNAME:-Unknown-Device}"
MAC="$(printf '%s' "$MACADDR" | tr '[:upper:]' '[:lower:]')"

touch "$KNOWN_FILE" || exit 1

# Skip notifications for known devices
if grep -Fxiq "$MAC" "$KNOWN_FILE"; then
    exit 0
fi

MESSAGE="⚠️ New device on the network!
Name: $HOST
IP: $IPADDR
MAC: $MAC"

# Send the notification via the Telegram Bot API
if curl -fsS --max-time 10 -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" --data-urlencode "chat_id=${CHAT_ID}" --data-urlencode "text=${MESSAGE}" >/dev/null 2>&1; then
    echo "$MAC" >> "$KNOWN_FILE"
    logger -t telegram-dhcp "Notification sent: $MAC $IPADDR"
else
    logger -t telegram-dhcp "Failed to send notification: $MAC"
fi

exit 0
