#!/usr/bin/env bats
load terraform_helper
load ip_address_helper
expected_internal_security_group_name="aws_security_group.web_workers_internal"
expected_external_security_group_name="aws_security_group.web_workers_external"
test_subject_internal_access="Ensure that our web workers internal security group"
test_subject_external_access="Ensure that our web workers external security group"
our_ip_address=$(get_our_public_ip_address)

@test "$test_subject_internal_access has a security group for internal access." {
  run get_terraform_plan_yml ".\"$expected_internal_security_group_name\""
  [ "$status" -eq 0 ]
}
@test "$test_subject_internal_access has the correct name." {
  run get_terraform_plan_yml ".\"$expected_internal_security_group_name\".name"
  [ "$output" == "web_workers_internal_sg" ]
}
@test "$test_subject_internal_access is mapped to the correct VPC." {
  run get_terraform_plan_yml ".\"$expected_internal_security_group_name\".vpc_id"
  [ "$output" == '${aws_vpc.main.id}' ]
}
@test "$test_subject_internal_access is open on all ports for all protocols to any instance with this rule" {
  expected_from_port=0
  expected_to_port=0
  expected_protocol="-1"
  expected_match_condition="self=true"
  run test_aws_security_group_ingress_rule "$expected_internal_security_group_name" \
    "$expected_from_port" \
    "$expected_to_port" \
    "$expected_protocol" \
    "$expected_match_condition"
  [ "$status" -eq 0 ]
}
@test "$test_subject_internal_access allows egress access out to the Internet." {
  expected_from_port=0
  expected_to_port=0
  expected_protocol="-1"
  expected_match_condition="cidr_blocks.0=0.0.0.0/0"
  run test_aws_security_group_egress_rule "$expected_internal_security_group_name" \
    "$expected_from_port" \
    "$expected_to_port" \
    "$expected_protocol" \
    "$expected_match_condition"
  [ "$status" -eq 0 ]
}

@test "$test_subject_external_access has a security group for external access." {
  run get_terraform_plan_yml ".\"$expected_external_security_group_name\""
  [ "$status" -eq 0 ]
}
@test "$test_subject_external_access has the correct name." {
  run get_terraform_plan_yml ".\"$expected_external_security_group_name\".name"
  [ "$output" == "web_workers_external_sg" ]
}
@test "$test_subject_external_access is mapped to the correct VPC." {
  run get_terraform_plan_yml ".\"$expected_external_security_group_name\".vpc_id"
  [ "$output" == '${aws_vpc.main.id}' ]
}
@test "$test_subject_external_access is open on port 22 for our IP address." {
  expected_from_port=22
  expected_to_port=22
  expected_protocol="tcp"
  expected_match_condition="cidr_blocks.0=$our_ip_address/32"
  run test_aws_security_group_ingress_rule "$expected_external_security_group_name" \
    "$expected_from_port" \
    "$expected_to_port" \
    "$expected_protocol" \
    "$expected_match_condition"
  [ "$status" -eq 0 ]
}
@test "$test_subject_external_access is open on port 80 for our IP address." {
  expected_from_port=80
  expected_to_port=80
  expected_protocol="tcp"
  expected_match_condition="cidr_blocks.0=$our_ip_address/32"
  run test_aws_security_group_ingress_rule "$expected_external_security_group_name" \
    "$expected_from_port" \
    "$expected_to_port" \
    "$expected_protocol" \
    "$expected_match_condition"
  [ "$status" -eq 0 ]
}
@test "$test_subject_external_access allows external egress access out to the Internet." {
  expected_from_port=0
  expected_to_port=0
  expected_protocol="-1"
  expected_match_condition="cidr_blocks.0=0.0.0.0/0"
  run test_aws_security_group_egress_rule "$expected_external_security_group_name" \
    "$expected_from_port" \
    "$expected_to_port" \
    "$expected_protocol" \
    "$expected_match_condition"
  [ "$status" -eq 0 ]
}
