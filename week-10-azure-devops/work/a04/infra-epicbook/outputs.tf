output "app_public_ip" {
  description = "Public IP address of the frontend VM that serves EpicBook through Nginx"
  value       = azurerm_public_ip.frontend.ip_address
}

output "mysql_fqdn" {
  description = "Private DNS name of the MySQL flexible server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "backend_private_ip" {
  description = "Private IP address of the backend VM"
  value       = azurerm_network_interface.backend.private_ip_address
}
