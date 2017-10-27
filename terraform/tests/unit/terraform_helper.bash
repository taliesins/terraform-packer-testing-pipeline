#!/usr/bin/env bash

get_terraform_plan_yml() {
  # Outputs Terraform plan into a human-readable format, converts it to
  # YML and then parses it using a provided filter.
  # We need to do this to overcome Terraform's inability to render
  # JSON from displayed tfstates.
  # 
  # Given the amount of development from HashiCorp against plan format,
  # this is unlikely to survive minor or major Terraform releases.
  # Use this at your own risk, or, even better, submit a pull request!
  yq_filter="$1"
  cat ./terraform.tfplan.out | \
    grep -E -v '(INFO|WARNING|ERROR):' | \
    sed 's/^<=/+/' | \
    sed -r 's/^[ ]{0,}\+ (.*)/\1:/g' | \
    tr -d $'\r' | \
    yq -e -r "$yq_filter"
}

test_aws_security_group_ingress_rule() {
  _test_aws_security_group_rule "$@" "ingress"
}

test_aws_security_group_egress_rule() {
  _test_aws_security_group_rule "$@" "egress"
}

_test_aws_security_group_rule() {
  # Tests that an AWS security group ingress rule against a rule string.
  # Format of the rule string is as follows:
  # <from_port>,<to_port>,<protocol>,<property_key>=<property_value>
  #
  # e.g. if I want to test against this ingress rule:
  # ingress {
  #   from_port = 22
  #   to_port = 22
  #   protocol = tcp
  #   self = true
  # }
  # The rule string under test would be: "22,22,tcp,self=true".
  #
  # NOTE: The property key must match what is shown by `terraform show`.
  # Consequently, if your property is a list (i.e. `cidr_blocks`), then you must
  # test against a given index (e.g. cidr_blocks.0=0.0.0.0/0).
  # Example: If you want to ensure that `cidr_blocks` = ['0.0.0.0/0', '10.1.0.0/24'],
  # you'll need to write two test cases, one against "cidr_blocks.0=0.0.0.0/0" and
  # another against "cidr_blocks.1=10.1.0.0/24'.
  resource_name="${1?Please provide a resource name to an aws_security_group resource.}"
  expected_from_port="${2?Please provide an expected from_port.}"
  expected_to_port="${3?Please provide an expected to_port.}"
  expected_protocol="${4?Please provide an expected protocol.}"
  expected_match_condition="${5?Please provide a condition to match security_group rules against.}"
  rule_type="${6?Please provide a rule type.}"
  # To make testing Terraform plans even more user unfriendly, Terraform uses a random
  # numeric identifier for every object in a list.
  # Therefore, the only way to really test against them is to do lots of JQ hacking.
  # TODO: Move this into `terraform_helper` if people actually begin using this concotion!
  property_to_find=$(echo "$expected_match_condition" | cut -f1 -d=)
  value_to_find=$(echo "$expected_match_condition" | cut -f2 -d=)

  # Let's go through this beast of a JQ filter, since there's really no way to
  # increase the readability of this one.
  #   `to_entries`: Turns an object into a list of `key`, `value objects.
  #   `map()`: Create a list based on the results obtained.
  #   `select((.key|match($condition)) and (.value == \"$condition\"))`:
  #     Find an object with the `.key` and `.value` that we want.
  #   `.[].key`: Obtain an array of keys from the evaluation above.
  #   `split(\".\")`: We want the randomly-assigned Terraform ID for this group, so split by periods.
  #   `.[1]`: Get the second element in that split (our ID).
  matching_security_group_ids=$(get_terraform_plan_yml ".\"$resource_name\" | \
    to_entries | \
    map(select((.key | match(\"$rule_type.[0-9]{1,}.$property_to_find\",\"x\")) and (.value == \"$value_to_find\"))) | 
    .[].key | \
    split(\".\") | \
    .[1]"
  )
  if [ -z "$matching_security_group_ids" ]
  then
    echo "Unable to find a security group ID for [$resource_name] that matches [$property_to_find]=[$value_to_find]"
    return 1
  fi
  rules_found=""
  while read -r security_group_id
  do
    expected_rule_for_this_id="$security_group_id,$expected_from_port,$expected_to_port,$expected_protocol,$value_to_find"
    actual_rule_for_this_id=$(
      printf "$security_group_id,"; 
      for property in from_port to_port protocol "$property_to_find"
      do
        get_terraform_plan_yml ".\"$resource_name\" | .\"$rule_type.$security_group_id.$property\""
      done | \
      tr "\n" ',' | \
      head -c -1
    )
    if [ $expected_rule_for_this_id == $actual_rule_for_this_id ]
    then
      return 0
    fi
    rules_found="${rules_found}${actual_rule_for_this_id}\n"
  done < <(echo "$matching_security_group_ids")
  echo "Unable to find an $rule_type rule that matched [$expected_rule_for_this_id]. Rules found: $rules_found" >&2
  return 1
}
