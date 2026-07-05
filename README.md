misalkan kita memiliki sebuah vm/ec2/server fresh install. kita tidak memiliki akses ke proxmox sehingga tidak dapat membuat user yg sudah langsung "jadi"
agar bisa sesuai dengan vm standar development, 
kita perlu menjalankan sebuah bootstrap ansible user yang akan kita gunakan sebagai user ansible pada vm tersebut, untuk mengatur ansible2 lainnya

ketentuan:
1. user ansible - user khusus untuk mengatur vm
2. key-only - login hanya dengan SSH Key, agar tidak kena bruteforce
3. auditable - user ansible dedicated, bisa dilacak aktivitasnya dan gampang direvoke
4. NOPASSWD sudo - akses dibatasi SSH key, aman, resiko lebih kecil dari pada password bocor di file

resiko yang dimitigasi
1. SSH key harus dijaga - jika private key bocor, vm fully compromised. simpan key terenkripsi atau gunakan ssh-agent
2. No logging granular — kalau perlu audit per-user, kombinasikan dengan sudo log_input / sudo log_output
3. bisa dibuat strict



## buat key ansible
```bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible
```

## update ~/.ssh/config
tambahkan
```bash
Host vm1
    HostName 192.168.68.100
    User ansible
    IdentityFile ~/.ssh/ansible_key
```

## 00-bootstrap-ansible-user.yml
1. membuat user ansible
2. menambahkan SSH public key
3. setup NOPASSWD sudo

setelah itu semua playbook pakai user ansible

```bash
cat 00-bootstrap-ansible-user.yml

---
- name: Bootstrap ansible user on all VMs
  hosts: vm
  become: true
  vars:
    ansible_user: "{{ bootstrap_user | default('ub') }}"
    ansible_public_key: "{{ lookup('file', '~/.ssh/ansible.pub') }}"

  tasks:
    - name: Create ansible user
      ansible.builtin.user:
        name: ansible
        state: present
        shell: /bin/bash
        create_home: yes

    - name: Create .ssh directory
      ansible.builtin.file:
        path: /home/ansible/.ssh
        state: directory
        owner: ansible
        group: ansible
        mode: '0700'

    - name: Deploy authorized_key
      ansible.builtin.authorized_key:
        user: ansible
        key: "{{ ansible_public_key }}"
        state: present

    - name: Setup NOPASSWD sudo
      ansible.builtin.copy:
        dest: /etc/sudoers.d/ansible
        content: 'ansible ALL=(ALL) NOPASSWD: ALL'
        owner: root
        group: root
        mode: '0440'
        validate: 'visudo -cf %s'
```
running dengan user vm (ub) dan --ask-become-pass:

```bash
ansible-playbook -i inventory.ini bootstrap-ansible-user.yml \
  -u ub --ask-become-pass -l vm1
```

## cara pakai
```bash

# Run playbook pada vm1 saja
make run c=install-git l=vm1

# Run playbook pada vm1 & vm2
make run c=install-git l=vm1,vm2

# Run playbook pada semua host
make run c=install-git

# Bootstrap VM baru (contoh vm2)
make bootstrap l=vm2 p=123654aa
```