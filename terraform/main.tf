provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.app_sg.name]

  root_block_device {
    volume_size           = 12    # Increased volume size to fix "no space left on device" error
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "TodoAppServer"
  }

  provisioner "local-exec" {
    command = "sleep 60"  # Fixes the "Failed to connect to the host via ssh" error
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    public_ip = aws_instance.app_server.public_ip
  })
  filename = "${path.module}/inventory"

  depends_on = [aws_instance.app_server]
}

resource "null_resource" "run_ansible" {
  triggers = {
    instance_id = aws_instance.app_server.id
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/inventory ../ansible/playbook.yml"
  }

  depends_on = [local_file.ansible_inventory]
}

resource "aws_security_group" "app_sg" {
  name_prefix = "todo-app-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}