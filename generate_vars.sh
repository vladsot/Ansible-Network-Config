#!/bin/bash

set -e

LOG_FILE="/tmp/generate_vars_$(date +%Y%m%d_%H%M%S).log"

# Log everything to file + console
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Network Configuration Input ==="
echo "Start time: $(date)"
echo "Log file: $LOG_FILE"

read -rp "Enter IP address (e.g. 192.168.1.10): " IP
read -rp "Enter subnet mask CIDR (e.g. 24): " MASK
read -rp "Enter gateway (e.g. 192.168.1.1): " GATEWAY
read -rp "Enter DNS servers (comma-separated, e.g. 8.8.8.8,8.8.4.4): " DNS

# Basic validation
if [[ -z "$IP" || -z "$MASK" || -z "$GATEWAY" || -z "$DNS" ]]; then
  echo "Error: All fields are required."
  exit 1
fi

# Convert DNS into YAML list
IFS=',' read -ra DNS_ARRAY <<< "$DNS"

VARS_FILE="vars.yml"

cat <<EOF > "$VARS_FILE"
ip_address: "$IP"
subnet_mask: "$MASK"
gateway: "$GATEWAY"
dns_servers:
$(for d in "${DNS_ARRAY[@]}"; do echo "  - $d"; done)
EOF

echo "Created $VARS_FILE"
echo "Run:"
echo "ansible-playbook configure_network.yml -e @$VARS_FILE"

echo "End time: $(date)"