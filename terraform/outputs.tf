output "instance_ip" {
  value = google_compute_instance.flask_app.network_interface[0].access_config[0].nat_ip
  description = "The public IP of the Flask application instance"
}
