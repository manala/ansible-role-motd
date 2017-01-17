.SILENT:
.PHONY: help templates

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Role
ROLE_NAME = manala.motd

## Macros
DOCKER = docker run \
    --rm \
    --volume `pwd`:/etc/ansible/roles/${ROLE_NAME} \
    --volume `pwd`:/srv \
    --workdir /srv \
    --tty \
    --cap-add SYS_PTRACE \
    ${DOCKER_OPTIONS} \
    manala/ansible-debian:${DEBIAN_DISTRIBUTION} \
    ${DOCKER_COMMAND}

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

#######
# Dev #
#######

dev@wheezy: DEBIAN_DISTRIBUTION = wheezy
dev@wheezy: DOCKER_OPTIONS      = --interactive
dev@wheezy: DOCKER_COMMAND      = /bin/bash
dev@wheezy:
	printf "${COLOR_INFO}Run docker...${COLOR_RESET}\n"
	$(DOCKER)

dev@jessie: DEBIAN_DISTRIBUTION = jessie
dev@jessie: DOCKER_OPTIONS      = --interactive
dev@jessie: DOCKER_COMMAND      = /bin/bash
dev@jessie:
	printf "${COLOR_INFO}Run docker...${COLOR_RESET}\n"
	$(DOCKER)

########
# Lint #
########

lint@wheezy: DEBIAN_DISTRIBUTION = wheezy
lint@wheezy: DOCKER_COMMAND      = make lint
lint@wheezy:
	printf "${COLOR_INFO}Run docker...${COLOR_RESET}\n"
	$(DOCKER)

lint@jessie: DEBIAN_DISTRIBUTION = jessie
lint@jessie: DOCKER_COMMAND      = make lint
lint@jessie:
	printf "${COLOR_INFO}Run docker...${COLOR_RESET}\n"
	$(DOCKER)

lint:
	ansible-lint -v .

########
# Test #
########

test@wheezy: DEBIAN_DISTRIBUTION = wheezy
test@wheezy: DOCKER_COMMAND      = sh -c 'make test'
test@wheezy:
	printf "${COLOR_INFO}Run docker...${COLOR_RESET}\n"
	$(DOCKER)

test@jessie: DEBIAN_DISTRIBUTION = jessie
test@jessie: DOCKER_COMMAND      = sh -c 'make test'
test@jessie:
	printf "${COLOR_INFO}Run docker...${COLOR_RESET}\n"
	$(DOCKER)

test: test-template

test-template:
	ansible-playbook tests/template.yml --syntax-check
	ansible-playbook tests/template.yml

#############
# Templates #
#############

templates:
	# Manala
	catimg -w 80 -r 1 templates/template/manala.png > templates/template/manala.j2
	echo "\n{{ manala_motd_message|center(80) }}" >> templates/template/manala.j2
	# Elao
	catimg -w 80 -r 1 templates/template/elao.png > templates/template/elao.j2
	echo "\n{{ manala_motd_message|center(80) }}" >> templates/template/elao.j2
