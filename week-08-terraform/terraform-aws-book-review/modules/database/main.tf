resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-terraform-db-subnets"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

resource "aws_db_instance" "primary" {
  identifier                = "${var.name}-db"
  engine                    = "mysql"
  engine_version            = "8.4"
  instance_class            = var.instance_class
  allocated_storage         = 20
  storage_type              = "gp3"
  storage_encrypted         = true
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [var.security_group_id]
  publicly_accessible       = false
  multi_az                  = true
  backup_retention_period   = var.backup_retention_days
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name}-db-final"
  deletion_protection       = var.deletion_protection
  apply_immediately         = true

  tags = {
    Name = "${var.name}-db-primary"
  }
}

resource "aws_db_instance" "replica" {
  identifier             = "${var.name}-db-replica"
  replicate_source_db    = aws_db_instance.primary.identifier
  instance_class         = var.instance_class
  storage_type           = "gp3"
  storage_encrypted      = true
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  deletion_protection    = false
  apply_immediately      = true

  tags = {
    Name = "${var.name}-db-replica"
  }
}
