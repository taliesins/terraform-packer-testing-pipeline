variable "aws_vpc_cidr_block" {
  description = "The CIDR block to use. Optional."
  default = "10.0.0.0/16"
}

variable "aws_ec2_key_name" {
  description = "Name to use for EC2 keys. Optional."
  default = "demo_machines"
}

variable "aws_ec2_key_pubkey" {
  description = "Public key to use for creating the EC2 instance key."
}
