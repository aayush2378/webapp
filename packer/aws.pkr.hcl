packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "DB_DATABASE" {
  type = string
}

variable "DB_HOST" {
  type = string
}

variable "DB_PORT" {
  type = number
}

variable "DB_USERNAME" {
  type = string
}

variable "DB_PASSWORD" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "source_ami" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami_users" {
  type    = list(string)
  default = []
}

source "amazon-ebs" "app-image" {
  ami_name      = "my-webapp-ami-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region
  access_key    = var.aws_access_key_id
  secret_key    = var.aws_secret_access_key

  # Specify the exact AMI ID here
  source_ami = var.source_ami # Replace with your actual AMI ID

  ssh_username = var.ssh_username

  # Specify VPC and subnet
  vpc_id    = var.vpc_id    # Replace with your actual VPC ID
  subnet_id = var.subnet_id # Replace with your actual Subnet ID

  ami_users = var.ami_users
}



build {
  sources = ["source.amazon-ebs.app-image"]

  provisioner "file" {
    source      = "./webapp.zip"
    destination = "/tmp/webapp.zip"
  }

  provisioner "file" {
    source      = "./packer/webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "file" {
    source      = "./packer/cloudwatch-config.json"
    destination = "/tmp/cloudwatch-config.json"
  }

  provisioner "file" {
    source      = "./packer/csye6225.conf"
    destination = "/tmp/csye6225.conf"
  }

  provisioner "shell" {
    scripts = [
      "./packer/scripts/create-user.sh",
      "./packer/scripts/setup.sh",
      "./packer/scripts/app-setup.sh",
      "./packer/scripts/systemd.sh",
      "./packer/scripts/cloudwatch.sh"
    ]
  }
}
