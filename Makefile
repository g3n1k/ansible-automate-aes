c ?= install-git
l ?=
p ?=
export ANSIBLE_SSH_PIPELINING ?= False

ssh_user ?= ub
ssh_host ?= localhost
ssh_port ?= 2222
ssh_password ?=
setup_user ?= ub
setup_host ?= waskop
setup_home ?= /home/$(setup_user)
setup_key ?=
setup_password ?=

default:
	@echo "Usage: make ans        -> ansible-playbook (need c=playbook l=limit)"
	@echo "       make bootstrap  -> bootstrap ansible user on VM (need l=vm1 p=password)"
	@echo "       make run        -> run playbook (need c=playbook l=limit)"
	@echo "       make setup-vm                         -> setup awal VM (user, password, key, home, hapus user, rename host, sudo ws)"
	@echo ""
	@echo "Examples:"
	@echo "  make run c=install-git l=vm1      # run on vm1 only"
	@echo "  make run c=install-git l=vm1,vm2  # run on vm1 & vm2"
	@echo "  make run c=install-git             # run on all hosts"
	@echo "  make bootstrap l=vm1 p=123654aa    # bootstrap vm1"
	@echo "  make setup-vm                         # setup awal vm"
	@echo "  make compliance                     # test SSH connectivity"
	@echo ""
	@echo "Targets:"
	@echo "  run         - run playbook"
	@echo "  bootstrap   - bootstrap ansible user on VM"
	@echo "  setup-vm    - setup awal VM (user, password, key, home, hapus user, rename host, sudo ws)"
	@echo "  install-ntp - install & sync NTP (chrony)"
	@echo "  compliance  - test SSH connectivity to servers"

run:
	ansible-playbook -i inventory.ini $(c).yml $(if $(l),-l $(l),) 

bootstrap:
	ansible-playbook -i inventory.ini 00-bootstrap-ansible-user.yml -l $(l) \
		--extra-vars 'ansible_become_password=$(p) bootstrap_user=$(if $(u),$(u),ub)' -vvv

setup-vm:
	ansible-playbook -i inventory.ini setup-vm.yml $(if $(l),-l $(l),) --extra-vars '{"ansible_host": "$(ssh_host)", "ansible_user": "$(ssh_user)", "ansible_port": $(ssh_port), "setup_user": "$(setup_user)", "setup_host": "$(setup_host)", "setup_home": "$(setup_home)", "setup_password": "$(setup_password)", "setup_key": "$(setup_key)", "ansible_password": "$(ssh_password)", "ansible_become_password": "$(if $(p),$(p),$(setup_password))"}'

# experimental
compliance:
	ansible-playbook -i inventory.ini compliance-test-server.yml $(if $(l),-l $(l),) -v

clear:
	echo "Cleaning up..."
	rm -rf ~/.ansible/cp/
