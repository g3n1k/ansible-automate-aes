#!/bin/bash
set -e
HOST="$1"
PASS="$2"
USER="${3:-ub}" # default user ub if not provided
PUBKEY_B64=$(cat ~/.ssh/ansible.pub | base64 -w0)

ssh -o StrictHostKeyChecking=no "${USER}@${HOST}" "
P='$PASS'
K=\$(echo '$PUBKEY_B64' | base64 -d)

echo \"\$P\" | sudo -S -p \"\" useradd -m -s /bin/bash ansible 2>/dev/null || true
echo \"\$P\" | sudo -S -p \"\" mkdir -p /home/ansible/.ssh

echo \"\$K\" > /tmp/ansible_pubkey
echo \"\$P\" | sudo -S -p \"\" cp /tmp/ansible_pubkey /home/ansible/.ssh/authorized_keys
rm -f /tmp/ansible_pubkey

echo \"\$P\" | sudo -S -p \"\" chown -R ansible:ansible /home/ansible/.ssh
echo \"\$P\" | sudo -S -p \"\" chmod 700 /home/ansible/.ssh
echo \"\$P\" | sudo -S -p \"\" chmod 600 /home/ansible/.ssh/authorized_keys

echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /tmp/ansible_sudoers
echo \"\$P\" | sudo -S -p \"\" cp /tmp/ansible_sudoers /etc/sudoers.d/ansible
rm -f /tmp/ansible_sudoers

echo \"\$P\" | sudo -S -p \"\" chmod 0440 /etc/sudoers.d/ansible

# Disable requiretty globally (required for Ansible non-TTY sudo)
echo \"\$P\" | sudo -S -p \"\" sed -i 's/^Defaults.*requiretty/#&/' /etc/sudoers

echo 'BOOTSTRAP_DONE'
"
