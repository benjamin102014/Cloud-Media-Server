resource "google_compute_instance" "filebrowser" {
  name         = "filebrowser-instance"
  machine_type = "e2-micro"
  zone         = "europe-central2-a"
  tags         = ["filebrowser"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "ansible:${file("${var.ssh_key_path}.pub")}"
  }
}

resource "google_compute_instance" "universalmediaserver" {
  name         = "universalmediaserver-instance"
  machine_type = "e2-micro"
  zone         = "europe-central2-a"
  tags         = ["ums"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "ansible:${file("${var.ssh_key_path}.pub")}"
  }
}