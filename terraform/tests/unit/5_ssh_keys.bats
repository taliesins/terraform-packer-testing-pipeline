#!/usr/bin/env bats
load terraform_helper

@test "Ensure that SSH key is using the correct public key" {
  expected_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7w4SfulFaS+opZoityxX+D9LtUihsfdOh4Id1VFEqDU+O1mo1kVw7LvQUJNdb5M+dRY0tjfUgZ1LnLQZb4GH5beLyHrJgWmVzwkJsdIGCFGWs3pMg3rVsLej5iabytxAO3SbM2vaYDfdIPdFWuwl7OndGJ0OvmuuYUsEsFEo513C+8KS2xCzBasmZfkKPkx13tfGRoFCRaXmJY448YCrGoyTKdfGdIQPGFcpVGo0bZDS0Sr3gFqVsvUyKCXwABKx6DDrlR9zLGOmVVaxRJhnF+Sdp3C0iwPy9XLbbHL7hVzCGf1HFf4a10gYikGdIrJFdtPL6r3jY8u8+K7xzEFp9 ubuntu@carlosonunez"
  run get_terraform_plan_yml '."aws_key_pair.main".public_key'
  [ "$output" == "$expected_pubkey" ]
}

@test "Ensure that SSH key is named correctly" {
  expected_name="demo_machines"
  run get_terraform_plan_yml '."aws_key_pair.main".key_name'
  [ "$output" == "$expected_name" ]
}
