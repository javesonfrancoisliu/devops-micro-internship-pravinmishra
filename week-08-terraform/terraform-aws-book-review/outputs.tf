output "public_alb_dns" {
  value = module.public_alb.dns_name
}

output "internal_alb_dns" {
  value = module.internal_alb.dns_name
}

output "db_writer_endpoint" {
  value = module.database.writer_endpoint
}

output "db_replica_endpoint" {
  value = module.database.replica_endpoint
}
