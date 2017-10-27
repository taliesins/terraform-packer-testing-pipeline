resource "aws_subnet" "web_workers" {
  cidr_block = "${var.web_workers_subnet_cidr_block}"
  vpc_id = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
  tags {
    Domain = "${var.domain}"
    Name = "web_workers"
  }
}
