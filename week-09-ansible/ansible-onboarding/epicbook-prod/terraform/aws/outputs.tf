output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "db_endpoint" {
  description = "Private MySQL endpoint host name"
  value       = aws_db_instance.mysql.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mysql.db_name
}

output "db_username" {
  description = "Database user name"
  value       = aws_db_instance.mysql.username
}
