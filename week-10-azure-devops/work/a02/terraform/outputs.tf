output "public_ip" {
  description = "Public IP address of the target VM"
  value       = aws_instance.target.public_ip
}

output "website_url" {
  description = "URL of the deployed website"
  value       = "http://${aws_instance.target.public_ip}"
}
