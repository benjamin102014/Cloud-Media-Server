output "filestore_ip" {
    value = google_filestore_instance.filestore.networks[0].ip_addresses[0]
}

output "filebrowser_ip" {
    value = google_compute_instance.filebrowser.network_interface[0].access_config[0].nat_ip
}

output "universalmediaserver_ip" {
    value = google_compute_instance.universalmediaserver.network_interface[0].access_config[0].nat_ip
}