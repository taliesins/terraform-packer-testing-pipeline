resource "aws_security_group" "web_workers_internal" {
  name = "web_workers_internal_sg"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_workers_external" {
  name = "web_workers_external_sg"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.our_public_ip_address}/32"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.our_public_ip_address}/32"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
