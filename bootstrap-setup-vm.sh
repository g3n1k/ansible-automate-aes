#!/bin/bash
set -e
HOST="$1"
PASS="$2"
USER="${3:-ub}"
HOME_DIR="${4:-/home/${USER}}"
PUBKEY_B64="${5:-$(cat ~/.ssh/ansible.pub | base64 -w0)}"

ssh -o StrictHostKeyChecking=no "${USER}@${HOST}" "
P='$PASS'
K=\$(echo '$PUBKEY_B64' | base64 -w0 | base64 -d)

echo \"\$P\" | sudo -S -p \"\" useradd -m -d \"${HOME_DIR}\" -s /bin/bash \"${USER}\" 2>/dev/null || true

if [ ! -d \"${HOME_DIR}\" ]; then
  mkdir -p \"${HOME_DIR}\"
fi

echo \"\$P\" | sudo -S -p \"\" mkdir -p \"${HOME_DIR}/.ssh\"
echo \"\$K\" > /tmp/bootstrap_setup_pubkey
echo \"\$P\" | sudo -S -p \"\" cp /tmp/bootstrap_setup_pubkey \"${HOME_DIR}/.ssh/authorized_keys\"
rm -f /tmp/bootstrap_setup_pubkey

echo \"\$P\" | sudo -S -p \"\" chown -R \"${USER}:${USER}\" \"${HOME_DIR}/.ssh\"
echo \"\$P\" | sudo -S -p \"\" chmod 700 \"${HOME_DIR}/.ssh\"
echo \"\$P\" | sudo -S -p \"\" chmod 600 \"${HOME_DIR}/.ssh/authorized_keys\"

echo \"${USER} ALL=(ALL) ALL\" > /tmp/bootstrap_sudoers
echo \"\$P\" | sudo -S -p \"\" cp /tmp/bootstrap_sudoers /etc/sudoers.d/${USER}
rm -f /tmp/bootstrap_sudoers
echo \"\$P\" | sudo -S -p \"\" chmod 0440 /etc/sudoers.d/${USER}

echo \"\$P\" | sudo -S -p \"\" sed -i 's/^Defaults.*requiretty/#&/' /etc/sudoers

echo \"\$P\" | sudo -S -p \"\" update-alternatives --set sudo /usr/bin/sudo.ws

echo 'BOOTSTRAP_SETUP_DONE'
"
