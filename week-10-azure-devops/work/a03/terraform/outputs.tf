output "public_ip" {
  description = "Public IP address of the React target VM"
  value       = aws_instance.target.public_ip
}

output "website_url" {
  description = "URL of the deployed React application"
  value       = "http://${aws_instance.target.public_ip}"
}
