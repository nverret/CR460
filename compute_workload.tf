
resource "google_compute_instance" "master-worker" {
  name         = "master-worker"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-subnet-workload"]

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.workload-network.name}"
    access_config {
    }
  }
}

resource "google_compute_instance_template" "coreos-template" {
  name        = "coreos-template"
  machine_type         = "f1-micro"
  can_ip_forward       = false

  // Create a new boot disk from an image
  disk {
    source_image = "coreos-cloud/coreos-stable"
    auto_delete = true
    boot = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.workload-network.name}"
  }
}

resource "google_compute_instance_group_manager" "workload-workers" {
  name        = "workload-workers"

  base_instance_name = "coreos-worker"
  instance_template  = "${google_compute_instance_template.coreos-template.self_link}"
  zone               = "us-east1-b"

}

resource "google_compute_autoscaler" "workers-autoscaler" {
  name   = "workers-autoscaler"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.workload-workers.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
