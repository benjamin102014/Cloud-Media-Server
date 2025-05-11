terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "6.34.0"
    }
  }
}

provider "google" {
    project = var.project_id
    region  = var.region
}

resource "google_compute_network" "vpc_network" {
    name = "terraform-network"
}

resource "google_compute_firewall" "firewall" {
    name    = "firewall"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports    = ["8080", "1044", "5001", "9001"]
    }

    allow {
        protocol = "udp"
        ports    = ["0-65535"]
    }

    allow {
        protocol = "icmp"
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internal" {
    name = "internal-communication"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports    = ["0-65535"]
    }

    allow {
        protocol = "udp"
        ports    = ["0-65535"]
    }

    source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_instance" "filebrowser" {
    name         = "filebrowser-instance"
    machine_type = "e2-micro"
    zone         = "europe-central2-a"

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
        startup-script = <<-EOT
            #!/bin/bash

            apt-get update
            apt-get install -y nfs-common docker.io

            mkdir -p /mnt/filestore
            echo "${google_filestore_instance.filestore.networks[0].ip_addresses[0]}:/filestore-share /mnt/filestore nfs defaults 0 0" >> /etc/fstab
            mount -a

            systemctl enable docker
            systemctl start docker

            # Initialize filebrowser.db and filebrowser.json
            mkdir -p /database
            touch /database/filebrowser.db
            cat <<EOF > /.filebrowser.json
            {
              "port": 80,
              "baseURL": "",
              "address": "",
              "log": "stdout",
              "database": "/database/filebrowser.db",
              "root": "/srv"
            }
            EOF

            # Wait for Filestore to be available
            while ! mountpoint -q /mnt/filestore; do
                sleep 5
                mount -a
            done
            
            docker run \
                -v /mnt/filestore:/srv \
                -v /database/filebrowser.db:/database.db \
                -v /.filebrowser.json:/.filebrowser.json \
                -u $(id -u):$(id -g) \
                -p 8080:80 \
                filebrowser/filebrowser:v2.32.0-s6
        EOT
    }
}

resource "google_compute_instance" "universalmediaserver" {
    name = "universalmediaserver-instance"
    machine_type = "e2-micro"
    zone = "europe-central2-a"
    
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
        startup-script = <<-EOT
            #!/bin/bash

            apt-get update
            apt-get install -y nfs-common docker.io

            mkdir -p /mnt/filestore
            echo "${google_filestore_instance.filestore.networks[0].ip_addresses[0]}:/filestore-share /mnt/filestore nfs defaults 0 0" >> /etc/fstab
            mount -a
            
            systemctl enable docker
            systemctl start docker

            # Wait for Filestore to be available
            while ! mountpoint -q /mnt/filestore; do
                sleep 5
                mount -a
            done

            docker run \
                -p 1044:1044 -p 5001:5001 -p 9001:9001 \
                -v /mnt/filestore/srv/UMS:/root/media \
                -v "$HOME"/.config/UMS:/root/.config/UMS \
                universalmediaserver/ums:14.12.1
        EOT
    }
}

resource "google_filestore_instance" "filestore" {
    name = "filestore-instance"
    tier = "BASIC_HDD"

    file_shares {
        name        = "filestore-share"
        capacity_gb = 1024
    }

    networks {
        network = google_compute_network.vpc_network.name
        modes   = ["MODE_IPV4"]
    }
}

