#!/usr/bin/env bats

load terraform_helper
expected_resource_name="aws_vpc.main"

@test "Ensure that VPC definition is present" {
  run get_terraform_plan_yml ".\"$expected_resource_name\""
  [ "$status" -eq 0 ]
}

@test "Ensure that VPC is using the correct CIDR block." {
  expected_cidr_block="10.0.0.0/16"
  run get_terraform_plan_yml ".\"$expected_resource_name\".\"cidr_block\""
  [ "$output" == "$expected_cidr_block" ]
}

@test "Ensure that we have an internet gateway." {
  run get_terraform_plan_yml '."aws_internet_gateway.main"."vpc_id"'
  [ "$output" == '${aws_vpc.main.id}' ]
}

@test "Ensure that we have a route out to the internet." {
  run get_terraform_plan_yml '."aws_route.vpc_to_internet_gateway"."destination_cidr_block"'
  [ "$output" == '0.0.0.0/0' ]
  run get_terraform_plan_yml '."aws_route.vpc_to_internet_gateway"."gateway_id"'
  [ "$output" == '${aws_internet_gateway.main.id}' ]
}
