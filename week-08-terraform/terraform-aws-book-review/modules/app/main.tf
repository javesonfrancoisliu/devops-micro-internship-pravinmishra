data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  count                       = length(var.subnet_ids)
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = false
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    region         = var.region
    repo_url       = var.repo_url
    db_host        = var.db_host
    db_name        = var.db_name
    db_secret_arn  = var.db_secret_arn
    jwt_secret_arn = var.jwt_secret_arn
    public_alb_dns = var.public_alb_dns
  })

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 12
    encrypted   = true
  }

  tags = {
    Name = "${var.name}-app-${count.index + 1}"
    Tier = "app"
  }
}

resource "aws_lb_target_group_attachment" "app" {
  count            = length(aws_instance.app)
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app[count.index].id
  port             = 3001
}
