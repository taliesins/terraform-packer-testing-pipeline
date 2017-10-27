# terraform-packer-testing-pipeline
An example of how to build a pipeline for deploying custom images onto infrastructure.

# How do I use this?

## Build your Packer image

1. `cd packer` to go into our Packer repository.
2. `make build` will build a simple NGINX image with Chef and run integration tests against it.

## Apply it onto infrastructure.

1. `cd ..\terraform` to go into our Terraform code.
2. `make build` will:
  - Initialize Terraform providers and modules (of which there are none in this example),
  - Validate that the code is correct,
  - Attempt to build a "dummy" plan for unit tests,
  - Run unit tests against the generated plan using [BATS](https://github.com/sstephenson/bats),
  - Deploy the infrastructure, then
  - Run a simple integration test against it, again with BATS.

**NOTE**: You can optionally use Serverspec to run these integration tests. To do so, 
open the `Makefile` and change the `integration_tests` target to `_integration_tests_serverspec`.

**NOTE**: You can also perform a few common Terraform actions, such as `plan` and `destroy`.
To do so, run `make terraform_$action`, where `$action` is the command that you would like to run.

## Errata

1. While we are using [semver](http://semver.org/) as our versioning scheme for our Packer images,
I did not include a way of tracking major, minor and patch versions.
2. Terraform variables and state are stored locally. This is against best practices. 
For security, we recommend storing them in a secure and external location such as S3.
3. We have not applied any state locking mechanism into our Terraform configuration. This is against best practices.
To prevent state collisions, use a backing store, such as DynamoDB, to hold a global state lock.
