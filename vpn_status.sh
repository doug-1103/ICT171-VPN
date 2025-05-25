#!/bin/bash

# vpn_status.sh - OpenVPN VPN Status Monitor
# Author: Douglas Phillip
# Description: This script checks the status of the OpenVPN server, lists connected users, logs bandwidth usage, and writes the results to a timestamped log file.

# Variables

STATUS_LOG="/var/log/openvpn/openvpn-status.log"  # Path to OpenVPN's status file
LOG_FILE="/var/log/vpn-status-check.log" # Where to write output log
VPN_SERVICE="openvpn@server"  #Service name for OpenVPN
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")  # Current timestamp

# Begin log entry

echo "[$TIMESTAMP] VPN Status Check" >> "$LOG_FILE"

# Check if OpenVPN is active

if sudo systemctl is-active --quiet "$VPN_SERVICE"; then
	echo "VPN Service: RUNNING" >> "$LOG_FILE"
else
	echo "VPN Service: NOT RUNNING" >> "$LOG_FILE"
	echo "[$TIMESTAMP] ERROR: VPN service is down!" >> "$LOG_FILE"
	exit 1
fi

# Check if the status log exists

if [ ! -f "$STATUS_LOG" ]; then
	echo "Status log not found at $STATUS_LOG" >> "$LOG_FILE"
	exit 1
fi

# Extract connected client info

echo "Connected Clients:" >> "$LOG_FILE"
awk '/Common Name/,/ROUTING TABLE/' "$STATUS_LOG" | sed '1d;$d' >> "$LOG_FILE"

# Count number of clients

# CLIENT_COUNT=$(awk '/Common Name/ { in_section=1; next } /ROUTING TABLE/ { in_section=0 } in_section { count++ }
CLIENT_COUNT=$(awk '
  BEGIN { count = 0 }
  /^Common Name,/ { in_section=1; next }
  /^ROUTING TABLE/ { in_section=0 }
  in_section && NF > 0 && $0 ~ /,/ { count++ }
  END { print count }
' "$STATUS_LOG")

#END { print count+0 }' "$STATUS_LOG")
echo "Client Count: $CLIENT_COUNT" >> "$LOG_FILE"

# Extract routing table info (bytes sent/received)

echo "Client Bandwidth Usage:" >> "$LOG_FILE"

# Separator

echo "------------------------------------------------" >> "$LOG_FILE"
