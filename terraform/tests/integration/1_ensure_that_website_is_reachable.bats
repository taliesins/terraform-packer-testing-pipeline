#!/usr/bin/env bats

@test "Ensure that website is reachable on all servers." {
  cat /tmp/web_server_ips | \
    while read -r web_server_ip;
    do
      run curl http://$web_server_ip
      echo "Expected status 0 from server $web_server_ip, but got $status"
      [ "$status" -eq 0 ]
    done
}
