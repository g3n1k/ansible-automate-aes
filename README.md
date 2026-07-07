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

### update vm
kita menggunakan Makefile untuk mempermudah command

```bash
make run c=update-vm l=vm1
```
