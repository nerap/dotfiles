terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# ── Network: reuse the default VPC. Nothing here is publicly reachable except SSH
# from your IP, and every dev port is tunnelled over SSH (see `devbox forwards`).

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "selected" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  default_for_az    = true
}

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "devbox" {
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "devbox" {
  name        = "${var.name}-sg"
  description = "devbox: inbound SSH from allowed CIDRs only; all dev ports go through SSH tunnels"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-sg" }
}

# ── IAM: SSM Session Manager, so you can still get a shell if your IP changes and
# the SG blocks you out. No inbound port needed for it.

resource "aws_iam_role" "devbox" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.devbox.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "devbox" {
  name = "${var.name}-profile"
  role = aws_iam_role.devbox.name
}

# ── Work volume: deliberately a SEPARATE volume from the root disk, so the box can
# be rebuilt/resized/replaced without ever putting the worktrees at risk.
# prevent_destroy means `terraform destroy` will refuse rather than eat your repos.

resource "aws_ebs_volume" "work" {
  availability_zone = var.availability_zone
  size              = var.work_volume_gb
  type              = "gp3"
  encrypted         = true

  tags = { Name = "${var.name}-work" }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "devbox" {
  ami                    = data.aws_ami.ubuntu_arm64.id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone
  subnet_id              = data.aws_subnet.selected.id
  key_name               = aws_key_pair.devbox.key_name
  vpc_security_group_ids = [aws_security_group.devbox.id]
  iam_instance_profile   = aws_iam_instance_profile.devbox.name

  # THE important line: when the idle-stop timer runs `shutdown -h`, the instance
  # STOPS (billing pauses) instead of terminating. Without this you'd lose the box.
  instance_initiated_shutdown_behavior = "stop"

  root_block_device {
    volume_size           = var.root_volume_gb
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # Kept deliberately tiny and secret-free (user-data is readable from instance
  # metadata). It only preps the disk + user. The real provisioning is push-based:
  # `devbox provision` runs bootstrap.sh over SSH with agent forwarding, so the box
  # clones your private repos using YOUR 1Password key and never holds a token.
  user_data = templatefile("${path.module}/user-data.sh", {
    username = var.username
  })

  tags = { Name = var.name }
}

resource "aws_volume_attachment" "work" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.work.id
  instance_id = aws_instance.devbox.id
}
