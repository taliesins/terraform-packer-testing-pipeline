#!/usr/bin/env bash
SSH_STATUS=255
SSH_OUTPUT=""

get_ssh_hosts() {
  ssh_hosts="$1"
  if [ -z "$ssh_hosts" ]
  then
    ssh_hosts="$SSH_HOSTS"
  fi
  if [ -z "$ssh_hosts" ]
  then
    exit 1
  fi
  echo "$ssh_hosts" | tr ',' "\n"
}

get_ssh_hosts_from_file() {
  file="$1"
  if [ ! -f "$file" ]
  then
    echo "ERROR: Doesn't exist - $file"
    exit 1
  fi
  cat "$file" | tr -d $'\r'
}

ssh_into_host_or_fail_test() {
  clear_ssh_variables
  host="$1"
  private_key_file="$2"
  command_to_run="${@:3}"
  SSH_OUTPUT=$(ssh -n -o "ConnectTimeout=3" \
    -o "StrictHostKeyChecking=no" \
    -i "$private_key_file" \
    ubuntu@"$host" "$command_to_run")
  SSH_STATUS=$?
  if [ "$SSH_STATUS" != 0 ]
  then
    return "$SSH_STATUS"
  fi
}

clear_ssh_variables() {
  SSH_STATUS=255
  SSH_OUTPUT=""
}
