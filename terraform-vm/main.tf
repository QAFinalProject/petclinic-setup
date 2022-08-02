# Install VM's modified from Leon Robinson

provider "aws" {
  region = "eu-west-2"
}

// Input Variables

variable "sshkeypairname" {
  type        = string
  description = "ssh keypair name in aws"
}

variable "small"  {
  default = "t2.small"
}

variable "micro"  {
  default = "t2.micro"
}

// Local Variables

locals {
  imageid      = "ami-05a8c865b4de3b127"
}

resource "aws_security_group" "nginx" {
  name = "nginx"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "app" {
  name = "app"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Frontend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Backend"
    from_port   = 9966
    to_port     = 9966
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "Cluster management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "Comms for nodes"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
      ingress {
    description = "Comms for nodes"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "Overlay"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "swarm-manager" {
  ami                    = local.imageid
  instance_type          = var.small
  key_name               = var.sshkeypairname
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = <<EOF
#cloud-config
# package_upgrade: true


EOF

  root_block_device {
    volume_size = 15
  }
  tags = {
    Name = "swarm-manager"
  }
}

resource "aws_instance" "nginx" {
  ami                    = local.imageid
  instance_type          = var.micro
  key_name               = var.sshkeypairname
  vpc_security_group_ids = [aws_security_group.nginx.id]
  user_data              = <<EOF
#cloud-config
package_upgrade: true
EOF

  root_block_device {
    volume_size = 8
  }
  tags = {
    Name = "nginx-lb"
  }
}

resource "aws_instance" "swarm-worker" {
  ami                    = local.imageid
  instance_type          = var.small
  key_name               = var.sshkeypairname
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = <<EOF
#cloud-config
package_upgrade: true
EOF

  root_block_device {
    volume_size = 15
  }
  tags = {
    Name = "swarm-worker"
  }
}

output "manager_IP" {
  value = aws_instance.swarm-manager.public_ip
}

output "nginx_IP" {
  value = aws_instance.nginx.public_ip
}

output "worker_IP" {
  value = aws_instance.swarm-worker.public_ip
}
