terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "flask_app" {
  name         = "flask-app-server"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Update and install dependencies
    apt-get update
    apt-get install -y docker.io git
    systemctl start docker
    systemctl enable docker

    # Add user to docker group
    usermod -aG docker ${var.ssh_user}

    # Clone the application
    git clone https://github.com/${var.github_username}/Starter-Flask-App.git /app
    cd /app

    # Build and run the Docker container
    docker build -t flask-app .
    docker run -d --name flask-app \
      --restart unless-stopped \
      -p 5000:5000 \
      flask-app

    # Install and configure gcloud
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-438.0.0-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-438.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh --quiet
  EOF

  tags = ["http-server", "https-server"]

  service_account {
    email  = google_service_account.flask_app.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "flask_app" {
  name    = "flask-app-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "5000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

resource "google_service_account" "flask_app" {
  account_id   = "flask-app-sa"
  display_name = "Flask App Service Account"
}