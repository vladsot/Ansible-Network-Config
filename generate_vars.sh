#!/bin/bash

set -e

echo "=== Network Configuration Input ==="

read -rp "Enter IP address (e.g. 192.168.1.10): " IP
read -rp "Enter subnet mask CIDR (e.g. 24): " MASK
read -rp "Enter gateway (e.g. 192.168.1.1): " GATEWAY
read -rp "Enter DNS servers (comma-separated): " DNS

if [[ -z "$IP" || -z "$MASK" || -z "$GATEWAY" || -z "$DNS" ]]; then
  echo "Error: All fields are required."
  exit 1
fi

IFS=',' read -ra DNS_ARRAY <<< "$DNS"

VARS_FILE="vars.yml"

cat <<EOF > $VARS_FILE
ip_address: "$IP"
subnet_mask: "$MASK"
gateway: "$GATEWAY"
dns_servers:
$(for d in "${DNS_ARRAY[@]}"; do echo "  - $d"; done)
EOF

echo "Created $VARS_FILE"
echo "Run:"
echo "ansible-playbook configure_network.yml -e @$VARS_FILE"