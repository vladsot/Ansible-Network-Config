#!/bin/bash

set -e

LOG_FILE="/tmp/generate_vars_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Network Configuration Input ==="
echo "Start time: $(date)"
echo "Log file: $LOG_FILE"

# =========================
# AUTO-DETECT CURRENT SETTINGS
# =========================
CURRENT_IP=$(ip -4 addr show scope global | awk '/inet/ {print $2}' | head -n1)
CURRENT_IP_ONLY=$(echo "$CURRENT_IP" | cut -d/ -f1)
CURRENT_MASK=$(echo "$CURRENT_IP" | cut -d/ -f2)

CURRENT_GATEWAY=$(ip route | awk '/default/ {print $3}' | head -n1)

CURRENT_DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | paste -sd "," -)

# Fallbacks if detection fails
CURRENT_IP_ONLY=${CURRENT_IP_ONLY:-"192.168.1.100"}
CURRENT_MASK=${CURRENT_MASK:-"24"}
CURRENT_GATEWAY=${CURRENT_GATEWAY:-"192.168.1.1"}
CURRENT_DNS=${CURRENT_DNS:-"8.8.8.8,8.8.4.4"}

echo "Detected current settings:"
echo "IP: $CURRENT_IP_ONLY/$CURRENT_MASK"
echo "Gateway: $CURRENT_GATEWAY"
echo "DNS: $CURRENT_DNS"
echo

# =========================
# USER INPUT WITH DEFAULTS
# =========================
read -rp "Enter IP address [$CURRENT_IP_ONLY]: " IP
IP=${IP:-$CURRENT_IP_ONLY}

read -rp "Enter subnet mask CIDR [$CURRENT_MASK]: " MASK
MASK=${MASK:-$CURRENT_MASK}

read -rp "Enter gateway [$CURRENT_GATEWAY]: " GATEWAY
GATEWAY=${GATEWAY:-$CURRENT_GATEWAY}

read -rp "Enter DNS servers comma-separated [$CURRENT_DNS]: " DNS
DNS=${DNS:-$CURRENT_DNS}

# =========================
# BASIC VALIDATION
# =========================
if [[ -z "$IP" || -z "$MASK" || -z "$GATEWAY" || -z "$DNS" ]]; then
  echo "Error: All fields are required."
  exit 1
fi

IFS=',' read -ra DNS_ARRAY <<< "$DNS"

VARS_FILE="vars.yml"

cat <<EOF > "$VARS_FILE"
ip_address: "$IP"
subnet_mask: "$MASK"
gateway: "$GATEWAY"
dns_servers:
$(for d in "${DNS_ARRAY[@]}"; do echo "  - $d"; done)
EOF

echo
echo "Created $VARS_FILE"
echo "Run:"
echo "ansible-playbook configure_network.yml -e @$VARS_FILE"

echo "End time: $(date)"