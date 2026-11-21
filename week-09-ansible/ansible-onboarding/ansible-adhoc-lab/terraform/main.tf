data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

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

resource "aws_key_pair" "lab" {
  key_name   = "ansible-adhoc-lab"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "ssh" {
  name        = "adhoc-lab-ssh"
  description = "SSH from the Ansible controller only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from the controller public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.controller_ip}/32"]
  }

  egress {
    description = "All outbound for package installs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name        = "adhoc-lab-web"
  description = "HTTP for web hosts only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  for_each = var.server_roles

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = each.key == "web" ? [aws_security_group.ssh.id, aws_security_group.web.id] : [aws_security_group.ssh.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "adhoc-lab-${each.key}"
    Role = each.key
  }
}
