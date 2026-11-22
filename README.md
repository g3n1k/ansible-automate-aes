# repo mempermudah setup vm

### clone
```bash
git clone https://github.com/g3n1k/ansible-automate-aes.git
```

### create key ansible
jangan gunakan passphrase

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible -N ""
```
- -t ed25519 — jenis key (lebih cepat & aman dari RSA)
- -f ~/.ssh/ansible — output file (.pub otomatis untuk public key)
- -N "" — tanpa passphrase (headless automation)

### inventory
```bash
cp example.inventory.ini inventory.ini
```
sesuaikan dengan arsitektur jaringan

### create ansible user
setup user ansible, 
- membuat remote user  
- mendisable ssh tty 

```bash
make bootstrap u=userVm p=passVm -l=vm1
```
check apakah user berhasil di create
```bash
ssh userVm@passVm "id ansible && sudo -l -U ansible"
```

### install ntp
setup NTP dengan chrony

```bash
make run c=install-ntp l=waskop
```

atau:

```bash
make install-ntp l=waskop
```

### update vm
kita menggunakan Makefile untuk mempermudah command

```bash
make run c=update-vm l=vm1
```

### setup awal vm
setup full vm (user, password, ssh key, home, hapus user lain, rename host, sudo ws)

```bash
make setup-vm ssh_user=ub ssh_host=localhost ssh_port=2222 ssh_password=MyPass123! setup_user=ub setup_host=waskop setup_home=/home/ub setup_key=stringkey setup_password=Passw0rd!
```

untuk vm spesifik (misal vm1):

```bash
make setup-vm l=vm1
```

atau pakai default (semua bisa di-override via make variable):

```bash
make setup-vm
```

cat file playbook `setup-vm.yml` dan script `bootstrap-setup-vm.sh`

- membuat user (custom username & home path) + password
- menambahkan ssh key ke authorized_keys
- membuat home
- hapus user lain
- rename hostname vm jadi `setup_host`
- setup sudo (`update-alternatives --set sudo /usr/bin/sudo.ws`)
- sudo tetap memakai password (tidak NOPASSWD)
