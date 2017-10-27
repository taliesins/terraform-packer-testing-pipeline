# This is an example of a Makefile that can be used to do Terraform runs.
# Using a Makefile or some kind of a build system moves code that would typically
# be written directly into a Jenkins jobs into source control.
# It also gives you a single invocation point to do Terraform-related things.
MAKEFLAGS += --silent
SHELL := /bin/bash

# Source environment variables from a .env file, if present.
$(shell if [ ! -f .env ]; then touch .env; fi)
include .env
export $(shell sed 's/=.*//' .env)

# Test for required env vars.
OUR_PUBLIC_IP_ADDRESS := $(shell curl -sL https://api.ipify.org)
REQUIRED_ENV_VARS := AWS_REGION \
	AWS_SECRET_ACCESS_KEY \
	AWS_ACCESS_KEY_ID \

# All of our binaries are run in Docker images for increased portability.
# As such, we need to expose our environment variables to our containers.
EXPOSED_DOCKER_ENV_VARS := $(foreach var,$(REQUIRED_ENV_VARS),-e $(var) )

# Main build actions.
.PHONY: init build
init:
	for var in $(REQUIRED_ENV_VARS); \
	do \
		if [ -z "$${!var+x}" ]; \
		then \
			echo -e "ERROR: $$var is unset. Export it or add it to .env first." >&2; \
			exit 1; \
		fi \
	done; \
	if [ -z "$$(docker images -q bats_yq)" ]; \
	then \
		docker build -t bats_yq -f bats_yq.dockerfile .; \
	fi

build: init \
	terraform_init terraform_get \
	lint unit_tests \
	terraform_apply \
	integration_tests

# Validate that our Terraform code is valid.
# Test suite.
.PHONY: lint unit_tests integration_tests
unit_tests: _create_plan_fixture _unit_tests
integration_tests: _get_web_server_addresses _integration_tests_bats
lint:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform validate \
		-var "our_public_ip_address=$(OUR_PUBLIC_IP_ADDRESS)" \
		-var-file=terraform.tfvars


# Run integration tests using Serverspec.
# TODO: Uncomment when spec files/structure are created.
#.PHONY: _integration_tests_serverspec
#	docker run --rm -v $$PWD/tests/integration/serverspec:/serverspec:ro -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
#		uzyexe/serverspec 

# Terraform actions.
.PHONY: terraform_init terraform_get terraform_plan terraform_apply terraform_destroy
terraform_init:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform init

terraform_get:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform get

terraform_plan:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform plan \
		-var "our_public_ip_address=$(OUR_PUBLIC_IP_ADDRESS)" \
		-var-file=terraform.tfvars

# Apply the plan to start the run.
terraform_apply:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform apply \
		-var "our_public_ip_address=$(OUR_PUBLIC_IP_ADDRESS)" \
		-var-file=terraform.tfvars

# Destroy the infrastructure create the plan.
terraform_destroy:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform destroy \
		-var "our_public_ip_address=$(OUR_PUBLIC_IP_ADDRESS)" \
		-var-file=terraform.tfvars

# We need a "dummy" plan to use for unit tests. This dummy plan is generated
# by giving Terraform the name of a state file that does not exist.
# This forces Terraform to generate a plan as if we were starting from
# nothing, which allows us to ensure that the code we wrote generates the
# plan that we expect (i.e. unit tests).
.PHONY: _create_plan_fixture
_create_plan_fixture:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform plan \
		-var "our_public_ip_address=$(OUR_PUBLIC_IP_ADDRESS)" \
		-var-file=terraform.tfvars \
		-state='blank_state_for_testing.tfstate' \
		-out='terraform.tfplan' && \
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform show -no-color terraform.tfplan > terraform.tfplan.out

.PHONY: _get_web_server_addresses
_get_web_server_addresses:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/terraform output web_worker_instance_ips > /tmp/web_worker_ips

# Run unit tests using BATS.
.PHONY: _unit_tests
_unit_tests:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		bats_yq tests/unit

# Run integration tests using BATS.
.PHONY: _integration_tests_bats
_integration_tests_bats:
	docker run --rm -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		bats_yq tests/integration
