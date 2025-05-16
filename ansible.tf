resource "ansible_host" "filebrowser" {
  name   = google_compute_instance.filebrowser.network_interface[0].access_config[0].nat_ip
  groups = ["filebrowser"]
  variables = {
    ansible_user                 = "ansible"
    ansible_become               = true
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    filestore_ip                 = google_filestore_instance.filestore.networks[0].ip_addresses[0]
  }
}

resource "ansible_host" "universalmediaserver" {
  name   = google_compute_instance.universalmediaserver.network_interface[0].access_config[0].nat_ip
  groups = ["universalmediaserver"]
  variables = {
    ansible_user                 = "ansible"
    ansible_become               = true
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    filestore_ip                 = google_filestore_instance.filestore.networks[0].ip_addresses[0]
  }
}