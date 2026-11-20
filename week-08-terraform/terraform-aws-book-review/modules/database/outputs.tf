output "writer_endpoint" {
  value = aws_db_instance.primary.address
}

output "replica_endpoint" {
  value = aws_db_instance.replica.address
}
