resource "aws_security_group" "this" {
  name        = var.traffic_gen.name
  description = "Workload security group"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = var.traffic_gen.name
  })
}

resource "aws_security_group_rule" "this_http" {
  type              = "ingress"
  description       = "Allow local HTTP inbound"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/16"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_ssh" {
  type              = "ingress"
  description       = "Allow local ssh inbound"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/16"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_icmp" {
  type              = "ingress"
  description       = "Allow all icmp"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/16"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_egress" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "workload_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "workload_key" {
  key_name   = "workload-key-${var.vpc_id}-${var.common_tags.Environment}"
  public_key = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : tls_private_key.workload_key.public_key_openssh
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.nano"
  ebs_optimized        = false
  monitoring           = true
  key_name             = aws_key_pair.workload_key.key_name
  subnet_id            = var.subnet_id
  iam_instance_profile = var.iam_instance_profile
  user_data = templatefile("${var.workload_template_path}/${var.workload_template}", {
    name     = var.traffic_gen.name
    apps     = join(",", var.traffic_gen.apps)
    external = join(",", var.traffic_gen.external)
    sap      = join(",", var.traffic_gen.sap)
    interval = var.traffic_gen.interval
    password = var.workload_password
  })
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.this.id]
  private_ip                  = var.traffic_gen.private_ip

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = merge(var.common_tags, {
    Name = var.traffic_gen.name
  })
}
