variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 20.04 LTS"
  type        = string
  default     = "ami-03f65b8614a860c29"  # Ubuntu 20.04 LTS in us-west-2
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for the instance"
  type        = string
  default     = "ubuntu"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-micro"
}

variable "github_username" {
  description = "GitHub username where the app repository is hosted"
  type        = string
}