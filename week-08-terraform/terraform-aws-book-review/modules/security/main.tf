resource "aws_security_group" "public_alb" {
  name        = "${var.name}-public-alb-sg"
  description = "Internet to the public load balancer on HTTP"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "To the web tier"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.name}-public-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.name}-web-sg"
  description = "Web tier reachable only from the public load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from the public load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }

  egress {
    description = "Outbound to the internet and the internal load balancer"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-web-sg"
  }
}

resource "aws_security_group" "internal_alb" {
  name        = "${var.name}-internal-alb-sg"
  description = "Internal load balancer reachable only from the web tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from the web tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "To the application tier"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.name}-internal-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Application tier reachable only from the internal load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "API port from the internal load balancer"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  egress {
    description = "Outbound through NAT and to the database"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "MySQL reachable only from the application tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from the application tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = {
    Name = "${var.name}-db-sg"
  }
}
