#!/usr/bin/env bats

@test "Ensure that we have a Terraform plan." {
  run ls terraform.tfplan
  [ "$status" -eq 0 ]
}

@test "Ensure that plan has been exported." {
  run ls terraform.tfplan.out
  [ "$status" -eq 0 ]
}
