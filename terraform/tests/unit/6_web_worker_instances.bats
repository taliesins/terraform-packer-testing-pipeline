#!/usr/bin/env bats
load terraform_helper
test_subject="Ensure that our web workers"
expected_resource_name="aws_instance.web_worker"

@test "$test_subject has three controllers." {
  controllers_found=$(
    get_terraform_plan_yml \
      ".|to_entries[]|select(.key|contains(\"$expected_resource_name\"))|.key" | \
      wc -l | \
      tr -d " "
  )
  [ "$controllers_found" -eq 3 ]
}

@test "$test_subject is using the correct SSH key" {
  expected_test_key='demo_machines'
  actual_key=$(
    for idx in $(seq 0 2)
    do
      get_terraform_plan_yml ".\"$expected_resource_name[$idx]\".key_name"
    done | sort -u
  )
  echo "Expected '$expected_test_key'; got '$actual_key'"
  [ "$expected_test_key" == "$actual_key" ]
}

@test "$test_subject are given names" {
  expected_name_array='web_worker-0,web_worker-1,web_worker-2'
  actual_name_array=$(
    for idx in $(seq 0 2)
    do
      get_terraform_plan_yml ".\"$expected_resource_name[$idx]\".\"tags.Name\""
    done | sort -u | tr "\n" ',' | head -c -1
  )
  echo "Expected '$expected_name_array'; got '$actual_name_array'"
  [ "$expected_name_array" == "$actual_name_array" ]
}

# There doesn't seem to be a good test for checking that security group
# linkages are correct, as the Terraform plan yields '<computed>'.
# Seems like one for the integration test.
# @test "$test_subject is using the correct security groups" { }
