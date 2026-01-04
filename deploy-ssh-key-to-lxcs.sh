#!/bin/bash

# SSH Key Deployment Script for LXCs via Proxmox Nodes

# Public key to deploy
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHKbUr2GyM3X5aAzOWf07OnKTL0o5t+30V4UmspaefC semaphore-ansible-automation"

# SSH key
SSH_KEY="/home/drego/ansible-project/playbooks/.ssh/semaphore-homelab"

# Counters
SUCCESS=0
FAILED=0
SKIPPED=0

echo "==============================================="
echo "  LXC SSH Key Deployment"
echo "==============================================="
echo ""

# Node 252 (proxmox1)
echo "Node: proxmox1 (192.168.1.252)"
for CTID in 100 102 104 106 108 300; do
    STATUS=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@192.168.1.252 "pct status $CTID" 2>/dev/null | awk '{print $2}')
    if [ "$STATUS" != "running" ]; then
        echo "  CT $CTID: SKIPPED (not running)"
        ((SKIPPED++))
        continue
    fi
    
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@192.168.1.252 \
        "pct exec $CTID -- mkdir -p /root/.ssh && \
         pct exec $CTID -- bash -c 'grep -qF \"$PUBLIC_KEY\" /root/.ssh/authorized_keys 2>/dev/null || echo \"$PUBLIC_KEY\" >> /root/.ssh/authorized_keys' && \
         pct exec $CTID -- chmod 700 /root/.ssh && \
         pct exec $CTID -- chmod 600 /root/.ssh/authorized_keys" 2>/dev/null; then
        echo "  CT $CTID: OK"
        ((SUCCESS++))
    else
        echo "  CT $CTID: FAILED"
        ((FAILED++))
    fi
done

# Node 230 (pve)
echo ""
echo "Node: pve (192.168.1.230)"
for CTID in 101 102 103 104 108 109 110 111 112 113 114 115 116 117; do
    STATUS=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@192.168.1.230 "pct status $CTID" 2>/dev/null | awk '{print $2}')
    if [ "$STATUS" != "running" ]; then
        echo "  CT $CTID: SKIPPED (not running)"
        ((SKIPPED++))
        continue
    fi
    
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@192.168.1.230 \
        "pct exec $CTID -- mkdir -p /root/.ssh && \
         pct exec $CTID -- bash -c 'grep -qF \"$PUBLIC_KEY\" /root/.ssh/authorized_keys 2>/dev/null || echo \"$PUBLIC_KEY\" >> /root/.ssh/authorized_keys' && \
         pct exec $CTID -- chmod 700 /root/.ssh && \
         pct exec $CTID -- chmod 600 /root/.ssh/authorized_keys" 2>/dev/null; then
        echo "  CT $CTID: OK"
        ((SUCCESS++))
    else
        echo "  CT $CTID: FAILED"
        ((FAILED++))
    fi
done

# Node 246 (zima2)
echo ""
echo "Node: zima2 (192.168.1.246)"
for CTID in 103 106 109 110 111 112; do
    STATUS=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@192.168.1.246 "pct status $CTID" 2>/dev/null | awk '{print $2}')
    if [ "$STATUS" != "running" ]; then
        echo "  CT $CTID: SKIPPED (not running)"
        ((SKIPPED++))
        continue
    fi
    
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@192.168.1.246 \
        "pct exec $CTID -- mkdir -p /root/.ssh && \
         pct exec $CTID -- bash -c 'grep -qF \"$PUBLIC_KEY\" /root/.ssh/authorized_keys 2>/dev/null || echo \"$PUBLIC_KEY\" >> /root/.ssh/authorized_keys' && \
         pct exec $CTID -- chmod 700 /root/.ssh && \
         pct exec $CTID -- chmod 600 /root/.ssh/authorized_keys" 2>/dev/null; then
        echo "  CT $CTID: OK"
        ((SUCCESS++))
    else
        echo "  CT $CTID: FAILED"
        ((FAILED++))
    fi
done

echo ""
echo "==============================================="
echo "Summary: $SUCCESS successful, $FAILED failed, $SKIPPED skipped"
echo "==============================================="
