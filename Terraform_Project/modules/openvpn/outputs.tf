output "openvpn_instance_id" {
  value       = aws_instance.openvpn.id
  description = "OpenVPN Access Server 인스턴스의 ID"
}

output "openvpn_public_ip" {
  value       = aws_instance.openvpn.public_ip
  description = "OpenVPN Access Server 인스턴스의 Public IP"
}
