data "aws_ami" "centos_nginx" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["centos-7-nginx-demo-*"]
  }
}
