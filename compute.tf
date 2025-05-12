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
    startup-script = <<-EOT
            #!/bin/bash

            echo "set man-db/auto-update false" | sudo debconf-communicate; sudo dpkg-reconfigure man-db

            sudo apt-get update
            sudo apt-get install -y nfs-common docker.io

            sudo mkdir -p /mnt/filestore
            echo "${google_filestore_instance.filestore.networks[0].ip_addresses[0]}:/filestore_share /mnt/filestore nfs defaults 0 0" | sudo tee -a /etc/fstab > /dev/null

            sudo mount -a
            while ! mountpoint -q /mnt/filestore; do
                sudo mount -a
                echo "Waiting for NFS mount..."
                sleep 1
            done

            sudo systemctl enable docker
            sudo systemctl start docker

            # Initialize filebrowser.db and filebrowser.json
            sudo mkdir -p /database
            sudo touch /database/filebrowser.db
            sudo bash -c 'cat <<EOF > /.filebrowser.json
            {
              "port": 80,
              "baseURL": "",
              "address": "",
              "log": "stdout",
              "database": "/database/filebrowser.db",
              "root": "/srv"
            }
            EOF'
            
            sudo docker run \
                -d \
                --privileged \
                --restart unless-stopped \
                -v /mnt/filestore:/srv \
                -v /database/filebrowser.db:/database.db \
                -v /.filebrowser.json:/.filebrowser.json \
                -p 8080:80 \
                filebrowser/filebrowser:v2.32.0-s6
        EOT
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
    startup-script = <<-EOT
            #!/bin/bash

            echo "set man-db/auto-update false" | sudo debconf-communicate; sudo dpkg-reconfigure man-db

            sudo apt-get update
            sudo apt-get install -y nfs-common docker.io

            sudo mkdir -p /mnt/filestore
            echo "${google_filestore_instance.filestore.networks[0].ip_addresses[0]}:/filestore_share /mnt/filestore nfs defaults 0 0" | sudo tee -a /etc/fstab > /dev/null
            
            sudo mount -a
            while ! mountpoint -q /mnt/filestore; do
                sudo mount -a
                echo "Waiting for NFS mount..."
                sleep 1
            done
            
            sudo systemctl enable docker
            sudo systemctl start docker

            # Create directories for UMS
            sudo mkdir -p /mnt/filestore/UMS
            sudo mkdir -p "$HOME"/.config/UMS

            docker run \
                -d \
                --restart unless-stopped \
                -p 1044:1044 -p 5001:5001 -p 9001:9001 \
                -v /mnt/filestore/UMS:/root/media \
                -v "$HOME"/.config/UMS:/root/.config/UMS \
                universalmediaserver/ums:14.12.1
        EOT
  }
}