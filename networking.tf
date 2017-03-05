
// region NETWORK
resource "google_compute_network" "cr460" {
  name                    = "cr460"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public-network" {
  name          = "public-network"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "workload-network" {
  name          = "workload-network"
  ip_cidr_range = "172.16.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "backend-network" {
  name          = "backend-network"
  ip_cidr_range = "192.168.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}
// endregion NETWORK

// region FIREWALL
resource "google_compute_firewall" "etcd" {
  name    = "etcd"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["2379","2380"]
  }
  source_ranges = ["10.0.1.0/24","172.16.1.0/24"]
  target_tags = ["tag-subnet-workload","tag-subnet-backend"]
}

resource "google_compute_firewall" "https" {
  name    = "https"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["tag-subnet-public"]
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
// endregion FIREWALL


resource "google_dns_record_set" "www" {
  name = "www.nverret.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "nverret"

  rrdatas = ["${google_compute_instance.vault.network_interface.0.access_config.0.assigned_nat_ip}"]
}
