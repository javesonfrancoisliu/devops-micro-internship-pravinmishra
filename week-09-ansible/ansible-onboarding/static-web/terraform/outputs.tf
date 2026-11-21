output "public_ips" {
  description = "Server name mapped to its public IP address"
  value       = { for name, instance in aws_instance.server : name => instance.public_ip }
}
