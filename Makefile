c ?= install-git
l ?= 
p ?=

default:
	@echo "Usage: make ans        -> ansible-playbook (need c=playbook l=limit)"
	@echo "       make bootstrap  -> bootstrap ansible user on VM (need l=vm1 p=password)"
	@echo "       make run        -> run playbook (need c=playbook l=limit)"
	@echo ""
	@echo "Examples:"
	@echo "  make run c=install-git l=vm1      # run on vm1 only"
	@echo "  make run c=install-git l=vm1,vm2  # run on vm1 & vm2"
	@echo "  make run c=install-git             # run on all hosts"
	@echo "  make bootstrap l=vm1 p=123654aa    # bootstrap vm1"
	@echo "  make compliance                     # test SSH connectivity"
	@echo ""
	@echo "Targets:"
	@echo "  run         - run playbook"
	@echo "  bootstrap   - bootstrap ansible user on VM"
	@echo "  compliance  - test SSH connectivity to servers"

run:
	ansible-playbook -i inventory.ini $(c).yml $(if $(l),-l $(l),) 

bootstrap:
	ansible-playbook -i inventory.ini 00-bootstrap-ansible-user.yml -l $(l) \
		--extra-vars 'ansible_become_password=$(p) bootstrap_user=ub' -vvv

# experimental
compliance:
	ansible-playbook -i inventory.ini compliance-test-server.yml $(if $(l),-l $(l),) -v

clear:
	echo "Cleaning up..."
	rm -rf ~/.ansible/cp/
