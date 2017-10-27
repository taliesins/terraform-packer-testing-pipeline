resource "aws_instance" "web_worker" {
  count = "${var.web_workers_count}"
  subnet_id = "${aws_subnet.web_workers.id}"
  ami = "${data.aws_ami.centos_nginx.id}"
  instance_type = "${var.web_workers_instance_type}"
  key_name = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.web_workers_external.id}",
    "${aws_security_group.web_workers_internal.id}"
  ]
  tags {
    Name = "${format("web_worker-%d",count.index)}"
  }
}
