resource "google_filestore_instance" "filestore" {
  name     = "filestore-instance"
  tier     = "BASIC_HDD"
  location = "europe-central2-a"

  file_shares {
    name        = "filestore_share"
    capacity_gb = 1024
  }

  networks {
    network = google_compute_network.vpc_network.name
    modes   = ["MODE_IPV4"]
  }
}