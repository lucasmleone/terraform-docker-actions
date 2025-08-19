output "vpc_id" {
  value       = aws_vpc.lab_vpc.id
  description = "ID de la VPC"
}

output "public_subnet_ids" {
  value       = [aws_subnet.lab_public_subnet1.id, aws_subnet.lab_public_subnet2.id]
  description = "IDs de subnets públicas"
}

output "private_subnet_ids" {
  value       = [aws_subnet.lab_private_subnet1.id, aws_subnet.lab_private_subnet2.id]
  description = "IDs de subnets privadas"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.lab_nat_gw.id
  description = "ID del NAT Gateway"
}

output "security_group_id" {
  value       = aws_security_group.allow_http.id
  description = "ID del Security Group de la aplicación"
}

output "web_server_public_ip" {
  value       = aws_instance.web_server1.public_ip
  description = "IP pública del servidor web"
}

output "web_server_public_dns" {
  value       = aws_instance.web_server1.public_dns
  description = "DNS público del servidor web"
}

output "web_server_url" {
  value       = "http://${aws_instance.web_server1.public_dns}/"
  description = "URL HTTP del servidor"
}
