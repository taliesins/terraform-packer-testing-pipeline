output "web_worker_instance_ips" {
  value = "${aws_instance.web_worker.*.public_ip}"
}
