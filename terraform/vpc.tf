resource "aws_vpc" "main" {
  cidr_block = "${var.aws_vpc_cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Domain = "${var.domain}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

data "aws_route_table" "main_vpc" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "vpc_to_internet_gateway" {
  route_table_id = "${data.aws_route_table.main_vpc.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.main.id}"
}
