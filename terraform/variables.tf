variable "ssh_username" {
  description = "SSH username for the instance"
  type        = string
  default     = "anshumanojha91"
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