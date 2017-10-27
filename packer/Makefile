# This is an example of a Makefile that can be used to do Packer runs.
# Using a Makefile or some kind of a build system moves code that would typically
# be written directly into a Jenkins jobs into source control.
# It also gives you a single invocation point to do Packer-related things.
MAKEFLAGS += --silent
SHELL := /bin/bash

# Source environment variables from a .env file, if present.
$(shell if [ ! -f .env ]; then touch .env; fi)
include .env
export $(shell sed 's/=.*//' .env)

# Test for required env vars.
REQUIRED_ENV_VARS := PACKER_TEMPLATE \
	AWS_VPC_ID \
	AWS_SUBNET_ID \
	AWS_REGION \
	AWS_SECRET_ACCESS_KEY \
	AWS_ACCESS_KEY_ID

# All of our binaries are run in Docker images for increased portability.
# As such, we need to expose our environment variables to our containers.
EXPOSED_DOCKER_ENV_VARS := $(foreach var,$(REQUIRED_ENV_VARS),-e $(var) )

# This step ensures that our environment is ready to continue.
# We use .PHONY markers to tell Make that these commands will not produce
# a file in the end (Make always assumes that a file is built).
.PHONY: init
init:
	for var in $(REQUIRED_ENV_VARS); \
	do \
		if [ -z "$${!var+x}" ]; \
		then \
			echo -e "ERROR: $$var is unset. Export it or add it to .env first." >&2; \
			exit 1; \
		fi \
	done \

# Validate that our Packer and Goss templates are valid.
.PHONY: validate
validate:
	docker run -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/packer validate \
		-var "aws_region=$(AWS_REGION)" \
		-var "aws_access_key=$(AWS_ACCESS_KEY_ID)" \
		-var "aws_secret_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "vpc_id=$(AWS_VPC_ID)" \
		-var "subnet_id=$(AWS_SUBNET_ID)" \
		$(PACKER_TEMPLATE) >/dev/null

# Build our template (after running tests).
.PHONY: build
build: init validate _build

# Build our template!
# Note that since we are using Goss to test that our cookbooks do what we want
# after they run, the tests run inside of this step.
# To see how these tests got made, check out:
# `cookbooks/{base,nginx}/files/goss.yml`.
# Goss documentation: https://github.com/aelsabbahy/goss/blob/master/docs/manual.md#port
.PHONY: _build
_build:
	docker run -v $$PWD:/app -w /app -it $(EXPOSED_DOCKER_ENV_VARS) \
		hashicorp/packer build \
		-var "aws_region=$(AWS_REGION)" \
		-var "aws_access_key=$(AWS_ACCESS_KEY_ID)" \
		-var "aws_secret_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "vpc_id=$(AWS_VPC_ID)" \
		-var "subnet_id=$(AWS_SUBNET_ID)" \
		$(PACKER_TEMPLATE)
