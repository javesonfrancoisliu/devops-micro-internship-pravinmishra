output "public_ip" {
  description = "Public IP address of the agent VM"
  value       = aws_instance.agent.public_ip
}
