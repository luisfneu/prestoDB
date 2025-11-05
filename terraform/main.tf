terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.name_prefix}-presto-data-${random_id.rand.hex}"
  force_destroy = true
}

resource "aws_s3_bucket" "config" {
  bucket = "${var.name_prefix}-presto-config-${random_id.rand.hex}"
  force_destroy = true
}

resource "random_id" "rand" {
  byte_length = 3
}

locals {
  bootstrap_files = fileset("${path.module}/../bootstrap", "**")
}

resource "aws_s3_object" "bootstrap" {
  for_each = { for f in local.bootstrap_files : f => f }
  bucket   = aws_s3_bucket.config.id
  key      = "bootstrap/${each.value}"
  source   = "${path.module}/../bootstrap/${each.value}"
  etag     = filemd5("${path.module}/../bootstrap/${each.value}")
  content_type = "text/plain"
}

resource "aws_s3_object" "data_csv" {
  bucket = aws_s3_bucket.data.id
  key    = "nyc/nyc_taxi_sample.csv"
  source = "${path.module}/../data/nyc_taxi_sample.csv"
  etag   = filemd5("${path.module}/../data/nyc_taxi_sample.csv")
  content_type = "text/csv"
}

resource "aws_glue_catalog_database" "nyc" {
  name = "${var.name_prefix}_nyc"
}

resource "aws_iam_role" "glue_crawler_role" {
  name = "${var.name_prefix}-glue-crawler-role-${random_id.rand.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "glue_crawler_policy" {
  name = "${var.name_prefix}-glue-crawler-policy-${random_id.rand.hex}"
  role = aws_iam_role.glue_crawler_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:*"],
        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["glue:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_glue_crawler" "nyc" {
  name         = "${var.name_prefix}-nyc-crawler"
  role         = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.nyc.name

  s3_target {
    path = "s3://${aws_s3_bucket.data.id}/nyc/"
  }

  schedule = "cron(0/30 * * * ? *)" # a cada 30 minutos
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter { name = "vpc-id" values = [data.aws_vpc.default.id] }
}

resource "aws_security_group" "presto_sg" {
  name   = "${var.name_prefix}-presto-sg-${random_id.rand.hex}"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2-presto-role-${random_id.rand.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.name_prefix}-ec2-presto-policy-${random_id.rand.hex}"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*",
          aws_s3_bucket.config.arn,
          "${aws_s3_bucket.config.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["glue:*"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["logs:*", "cloudwatch:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-presto-profile-${random_id.rand.hex}"
  role = aws_iam_role.ec2_role.name
}
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "presto" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.presto_sg.id]
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.ssh_key_name == "" ? null : var.ssh_key_name

  user_data = templatefile("${path.module}/user_data.tpl", {
    CONFIG_BUCKET = aws_s3_bucket.config.id
  })

  tags = {
    Name = "${var.name_prefix}-presto-ec2"
  }
}

output "presto_public_dns" {
  value = aws_instance.presto.public_dns
}

output "presto_url" {
  value = "http://${aws_instance.presto.public_dns}:8080"
}

output "data_bucket" {
  value = aws_s3_bucket.data.id
}

output "config_bucket" {
  value = aws_s3_bucket.config.id
}
