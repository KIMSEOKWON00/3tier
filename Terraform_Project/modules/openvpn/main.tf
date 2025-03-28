resource "aws_instance" "openvpn" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  source_dest_check           = false
  vpc_security_group_ids      = var.vpc_security_group_ids

  tags = merge(
    {
      Name = "openvpn-server"
    },
    var.instance_tags
  )
}
