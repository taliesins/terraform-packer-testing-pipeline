resource "aws_key_pair" "main" {
  key_name = "${var.aws_ec2_key_name}"
  public_key = "${var.aws_ec2_key_pubkey}"
}
