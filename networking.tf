resource "google_compute_network" "cr460" {
  name                    = "cr460"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public_Network" {
  name          = "public_Network"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "workload_network" {
  name          = "workload_network"
  ip_cidr_range = "172.16.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "backend_network" {
  name          = "backend_network"
  ip_cidr_range = "192.168.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_firewall" "web" {
  name    = "web"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

resource "google_dns_record_set" "www" {
  name = "www.nverret.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "nverret"

  rrdatas = ["${google_compute_instance.instance1.network_interface.0.access_config.0.assigned_nat_ip}"]
}
