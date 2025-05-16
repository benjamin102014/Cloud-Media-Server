terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.34.0"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
  required_version = ">= 1.12.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}
