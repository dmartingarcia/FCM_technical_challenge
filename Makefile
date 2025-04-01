# Default target
.DEFAULT_GOAL := help

# Vars
DOCKER_COMPOSE = docker compose
DOCKER_EXEC = docker compose run --remove-orphans --rm app

# Phony targets, this will prevent make/autotools from being confused with files/folders that could have the same name than a folder
.PHONY: help build run audit linter test

help: # Show all commands
	@echo "Available commands:"
	@awk '/^[a-zA-Z_-]+:/ {print $$1 "\t" substr($$0, index($$0, "#") + 2)}' $(MAKEFILE_LIST)

shell: # Starts an interactive shell
	@$(DOCKER_COMPOSE) run -it --rm app sh

build: # Builds the Docker images using docker-compose
	@$(DOCKER_COMPOSE) build

bundle-install: # Runs bundle install
	@$(DOCKER_EXEC) bundle install

run: build # Runs the Ruby script with input.txt or the specified file
	command = ruby main.rb $(if $(filter-out $@,$(MAKECMDGOALS)),$(filter-out $@,$(MAKECMDGOALS)),input.txt)
	@echo "Running command: $(command)"
	@$(DOCKER_EXEC) $(command)

# Audit command
audit: # Runs security and dependency audits
	$(DOCKER_EXEC) bundler audit
	$(DOCKER_EXEC) brakeman

# Linter command
linter: # Runs all Ruby linters
	@$(DOCKER_COMPOSE) run --rm -T app bundle exec rubocop $(filter-out $@,$(MAKECMDGOALS))

# Test command
test: bundle-install # Runs tests using RSpec
	@$(DOCKER_EXEC) bundle exec rspec --color $(filter-out $@,$(MAKECMDGOALS))