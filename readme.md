# Telegram Alerts for New Devices on FriendlyWrt

FriendlyWrt provides native DHCP event handling through the `/etc/hotplug.d/dhcp/` directory. On an OpenWrt-compatible system, scripts in this directory run when DHCP events occur, with `ACTION`, `MACADDR`, `IPADDR`, and `HOSTNAME` passed as environment variables.

This is more convenient than configuring `dhcpscript` separately in `dnsmasq`.

> **Important:** DHCP Hotplug tracks IP address assignments and renewals, not every Wi-Fi connection.

## 1. Create the Hotplug Script

Run the following commands over SSH:

```sh
mkdir -p /etc/hotplug.d/dhcp
vi /etc/hotplug.d/dhcp/90-telegram-alert
```

Paste the contents of [90-telegram-alert.sh](90-telegram-alert.sh) into the file.

Replace the token and chat ID placeholders (`YOUR_TELEGRAM_BOT_TOKEN` and `YOUR_TELEGRAM_CHAT_ID`) with your own values. Then run:

```sh
chmod 700 /etc/hotplug.d/dhcp/90-telegram-alert
touch /etc/known_macs
chmod 600 /etc/known_macs
```

Restarting `dnsmasq` is usually unnecessary: Hotplug runs the scripts when events occur.

## 2. Verify the Setup

Check the system log:

```sh
logread -e telegram-dhcp
```

### Troubleshoot DHCP Events

To check whether DHCP events reach Hotplug, create a temporary diagnostic script:

```sh
cat > /etc/hotplug.d/dhcp/00-debug <<'EOF'
#!/bin/sh
logger -t dhcp-debug \
  "ACTION=$ACTION MACADDR=$MACADDR IPADDR=$IPADDR HOSTNAME=$HOSTNAME"
EOF

chmod 755 /etc/hotplug.d/dhcp/00-debug
```

Reconnect a test device to the network, then check the log:

```sh
logread -e dhcp-debug
```

After troubleshooting, you can delete `/etc/hotplug.d/dhcp/00-debug`.

## 3. Important Notes

- A device is added to the database only after its Telegram notification is sent successfully.
- `ACTION=update` does not trigger a duplicate notification.
- Clearing `/etc/known_macs` causes all devices to be treated as new.
- Tracking every Wi-Fi connection, including known devices connecting without a new DHCP lease, requires an additional Wi-Fi event handler.
