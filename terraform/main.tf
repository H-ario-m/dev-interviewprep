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
    set -e  # Exit on any error
    exec > >(tee -a /var/log/startup-script.log) 2>&1  # Log all output

    echo "Starting startup script..."

    # Update and install dependencies
    apt-get update
    apt-get install -y docker.io git

    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Verify Docker is running
    if ! systemctl is-active --quiet docker; then
        echo "Docker failed to start. Attempting to fix..."
        systemctl restart docker
    fi

    # Add user to docker group
    usermod -aG docker ${var.ssh_user}

    # Remove existing app directory if exists
    rm -rf /app

    echo "Cloning application..."
    # Clone the application
    git clone https://github.com/${var.github_username}/Starter-Flask-App.git /app
    cd /app

    echo "Building Docker image..."
    # Build and run the Docker container with error handling
    if docker build -t flask-app .; then
        echo "Docker build successful"
        
        # Stop and remove existing container if exists
        docker stop flask-app 2>/dev/null || true
        docker rm flask-app 2>/dev/null || true
        
        echo "Starting container..."
        # Run new container
        docker run -d --name flask-app \
            --restart unless-stopped \
            -p 5000:5000 \
            flask-app

        # Verify container is running
        if docker ps | grep flask-app; then
            echo "Container started successfully"
        else
            echo "Container failed to start. Checking logs..."
            docker logs flask-app
        fi
    else
        echo "Docker build failed"
        exit 1
    fi

    echo "Startup script completed"
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