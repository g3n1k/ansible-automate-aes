#!/bin/bash
set -e
HOST="$1"
PASS="$2"
PUBKEY_B64=$(cat ~/.ssh/ansible.pub | base64 -w0)

ssh -o StrictHostKeyChecking=no "$HOST" "
P='$PASS'
K=\$(echo '$PUBKEY_B64' | base64 -d)

echo \"\$P\" | sudo -S -p \"\" useradd -m -s /bin/bash ansible 2>/dev/null || true
echo \"\$P\" | sudo -S -p \"\" mkdir -p /home/ansible/.ssh

# Write pubkey to temp file, then sudo-cp
echo \"\$K\" > /tmp/ansible_pubkey
echo \"\$P\" | sudo -S -p \"\" cp /tmp/ansible_pubkey /home/ansible/.ssh/authorized_keys
rm -f /tmp/ansible_pubkey

echo \"\$P\" | sudo -S -p \"\" chown -R ansible:ansible /home/ansible/.ssh
echo \"\$P\" | sudo -S -p \"\" chmod 700 /home/ansible/.ssh
echo \"\$P\" | sudo -S -p \"\" chmod 600 /home/ansible/.ssh/authorized_keys

# Write sudoers to temp file, then sudo-cp
echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /tmp/ansible_sudoers
echo \"\$P\" | sudo -S -p \"\" cp /tmp/ansible_sudoers /etc/sudoers.d/ansible
rm -f /tmp/ansible_sudoers

echo \"\$P\" | sudo -S -p \"\" chmod 0440 /etc/sudoers.d/ansible
echo 'BOOTSTRAP_DONE'
"
