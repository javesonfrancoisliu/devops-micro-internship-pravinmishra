output "public_ips" {
  description = "Server role mapped to its public IP address"
  value       = { for role, instance in aws_instance.server : role => instance.public_ip }
}

output "instance_ids" {
  description = "Server role mapped to its instance ID"
  value       = { for role, instance in aws_instance.server : role => instance.id }
}
