terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Fixed spelling error
      version = "~> 5.0"
    }
  }
}

variable "aws_provider_region" {
  type        = string
  description = "The AWS region to deploy the resource to"
  default     = "us-east-1"
}

variable "aws_subnet_a_availability_zone" {
  type        = string
  description = "Availability zone for AWS Subnet A"
}

variable "aws_subnet_b_availability_zone" {
  type        = string
  description = "Availability zone for AWS Subnet B" # Moved string from default to description
}

provider "aws" {
  region = var.aws_provider_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ads-platform-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24" # First block: 10.0.0.0 to 10.0.0.255
  availability_zone       = var.aws_subnet_a_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "ads-platform-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"                      # Fixed overlapping CIDR range
  availability_zone       = var.aws_subnet_b_availability_zone # Fixed mapping to use subnet B's variable
  map_public_ip_on_launch = true                               # Fixed argument name typo

  tags = {
    Name = "ads-platform-public-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ads-platform-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id # Changed gateway to gateway_id for standard syntax
  }

  tags = {
    Name = "ads-platform-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id # Fixed resource reference path
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id # Fixed resource reference path
}

resource "aws_security_group" "web" {
  name   = "ads-platform-web"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443 # Fixed port range typo (433 -> 443)
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
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ads-platform-web-sg"
  }
}
