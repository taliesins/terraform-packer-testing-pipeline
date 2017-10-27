#!/usr/bin/env bats
load terraform_helper
expected_resource_name="aws_subnet.web_workers"
test_subject="Ensure that our web_workers subnet"

@test "$test_subject has a subnet." {
  run get_terraform_plan_yml ".\"$expected_resource_name\""
  [ "$status" -eq 0 ]
}

@test "$test_subject is using the right CIDR." {
  expected_cidr="10.0.2.0/24"
  run get_terraform_plan_yml ".\"$expected_resource_name\".cidr_block"
  [ "$output" == "$expected_cidr" ]
}

@test "$test_subject is mapped to the correct VPC." {
  run get_terraform_plan_yml ".\"$expected_resource_name\".vpc_id"
  [ "$output" == '${aws_vpc.main.id}' ]
}

@test "$test_subject does not automatically assign public IP addresses." {
  run get_terraform_plan_yml ".\"$expected_resource_name\".map_public_ip_on_launch"
  [ "$output" == "true" ]
}

@test "$test_subject has the correct name." {
  run get_terraform_plan_yml ".\"$expected_resource_name\".\"tags.Name\""
  [ "$output" == "web_workers" ]
}

@test "$test_subject has the correct domain." {
  run get_terraform_plan_yml ".\"$expected_resource_name\".\"tags.Domain\""
  [ "$output" == "carlosnunez.me" ]
}
