variable "web_workers_subnet_cidr_block" {
  description = "The subnet CIDR to use for our web workers."
}

variable "web_workers_instance_type" {
  description = "Instance type to use for our controllers."
  default = "t2.micro"
}

variable "web_workers_count" {
  description = "The number of workers to provision."
  default = 3
}
