# Default target
.DEFAULT_GOAL := help

# Vars
UID := $(shell id -u)
GID := $(shell id -g)
DOCKER_COMPOSE := UID=$(UID) GID=$(GID) docker compose
DOCKER_EXEC := $(DOCKER_COMPOSE) run --remove-orphans --rm -T app

# Phony targets, this will prevent make/autotools from being confused with files/folders that could have the same name than a folder
.PHONY: help build run audit linter test

help: # Show all commands
	@echo "Available commands:"
	@awk '/^[a-zA-Z_-]+:/ {print $$1 "\t" substr($$0, index($$0, "#") + 2)}' $(MAKEFILE_LIST)

shell: # Starts an interactive shell
	@$(DOCKER_COMPOSE) run -it --rm app sh

# INFO: Add BUILDKIT_PROGRESS=plain for debugging the docker build
build: # Builds the Docker images using docker-compose
	@$(DOCKER_COMPOSE) build

bundle-install: # Runs bundle install
	@$(DOCKER_EXEC) bundle install

run: build bundle-install # Runs the Ruby script with input.txt or the specified file. e.g: make run input.txt
	@$(eval input_file := $(if $(filter-out $@,$(MAKECMDGOALS)),$(filter-out $@,$(MAKECMDGOALS)),input.txt))
	@echo "Running command: ruby main.rb $(input_file)"
	@$(DOCKER_EXEC) bundle exec ruby main.rb $(input_file)

# Audit command
audit: # Runs security and dependency audits
	@$(DOCKER_EXEC) bundle exec rubycritic --no-browser
	@$(DOCKER_EXEC) bundle exec bundler-audit check --update

# Linter command
linter: # Runs all Ruby linters
	@$(DOCKER_EXEC) bundle exec rubocop $(filter-out $@,$(MAKECMDGOALS))

# Test command
test: bundle-install # Runs tests using RSpec
	@$(DOCKER_EXEC) bundle exec rspec --color $(filter-out $@,$(MAKECMDGOALS))