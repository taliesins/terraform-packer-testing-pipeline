#!/usr/bin/env bash
get_our_public_ip_address() {
  if [ ! -f /tmp/our_public_ip_address ]
  then
    curl -sL https://api.ipify.org > /tmp/our_public_ip_address
  fi
  cat /tmp/our_public_ip_address
}
