locals {
  gcp_credentials               = var.credentials
  gcp_project_id                = var.gcp_project
  mirror_vpc_network_id         = var.mirror_vpc_network
  mirror_vpc_network_project_id = element(split("/", local.mirror_vpc_network_id), 1)
  mirror_vpc_network_region     = element(split("/", local.mirror_vpc_network_id), 4)
  mirror_vpc_subnet_cidr        = [for subnet in var.subnets : subnet.mirror_vpc_subnet_cidr]

  packet_mirroring_mirror_subnet_sources   = var.mirror_vpc_subnets
  packet_mirroring_mirror_tag_sources      = var.mirror_vpc_tags
  packet_mirroring_mirror_instance_sources = var.mirror_vpc_instances

  collector_vpc_name        = var.vpc_name
  collector_vpc_subnet_cidr = [for subnet in var.subnets : subnet.collector_vpc_subnet_cidr]
  collector_vpc_subnets = {
    for subnet in var.subnets :
    "${subnet.collector_vpc_subnet_region}/${subnet.collector_vpc_subnet_cidr}" => subnet
  }
  collector_subnet_ids = [for subnet in google_compute_subnetwork.main : subnet.id]

}

provider "google" {
  credentials = local.gcp_credentials
  project     = local.gcp_project_id
}

# -------------------------------------------------------------- #
# VPC NETWORK
# -------------------------------------------------------------- #

resource "google_compute_network" "main" {
  name                            = local.collector_vpc_name
  routing_mode                    = var.vpc_routing_mode
  description                     = var.vpc_description
  auto_create_subnetworks         = var.auto_create_subnetworks
  delete_default_routes_on_create = var.delete_default_internet_gateway_routes
  mtu                             = var.mtu
}


resource "google_compute_subnetwork" "main" {
  for_each                 = local.collector_vpc_subnets
  name                     = format("%s-%02d", "subnet", index(var.subnets, each.value) + 1)
  ip_cidr_range            = each.value.collector_vpc_subnet_cidr
  region                   = each.value.collector_vpc_subnet_region
  private_ip_google_access = var.private_ip_google_access
  network                  = google_compute_network.main.self_link
  depends_on               = [google_compute_network.main]
}

# -------------------------------------------------------------- #
# FIREWALL-RULES
# -------------------------------------------------------------- #

resource "google_compute_firewall" "allow-health-check" {
  name      = "${local.collector_vpc_name}-rule-allow-health-check"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  depends_on    = [google_compute_subnetwork.main]
}

resource "google_compute_firewall" "allow_ingress" {
  name      = "${local.collector_vpc_name}-rule-allow-ingress"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  allow {
    protocol = "all"
  }
  source_ranges = local.mirror_vpc_subnet_cidr
  depends_on    = [google_compute_subnetwork.main]
}

resource "google_compute_firewall" "allow_egress" {
  name      = "${local.mirror_vpc_network_region}-rule-allow-egress"
  network   = local.mirror_vpc_network_region
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = local.collector_vpc_subnet_cidr
  depends_on         = [google_compute_subnetwork.main]
}

# -------------------------------------------------------------- #
# VPC-PEERING
# -------------------------------------------------------------- #

resource "google_compute_network_peering" "mirror_vpc_network_peering" {
  name                 = "network-peering-mirror-to-collector"
  network              = local.mirror_vpc_network_id
  peer_network         = google_compute_network.main.id
  export_custom_routes = var.export_local_custom_routes
  import_custom_routes = var.export_peer_custom_routes
  depends_on           = [google_compute_subnetwork.main]
}

resource "google_compute_network_peering" "collector_vpc_network_peering" {
  name                 = "network-peering-collector-to-mirror"
  network              = google_compute_network.main.id
  peer_network         = local.mirror_vpc_network_id
  export_custom_routes = var.export_peer_custom_routes
  import_custom_routes = var.export_local_custom_routes

  depends_on = [google_compute_network_peering.mirror_vpc_network_peering]
}

# -------------------------------------------------------------- #
# INSTANCE-TEMPLATE
# -------------------------------------------------------------- #

resource "google_compute_instance_template" "main" {
  for_each    = google_compute_subnetwork.main
  name        = format("%s--%s", "collector-it", element(split("/", each.value.id), 3))
  description = var.template_description
  metadata_startup_script = templatefile(
    "${path.module}/files/startup_script.sh",
    {
      vpc_id     = local.mirror_vpc_network_id,
      project_id = local.mirror_vpc_network_project_id,
      vpc_name   = local.mirror_vpc_network_region,
      creds      = file(var.credentials),
      ip_cidrs   = format("%s\tcollector-region: %s\n", element([for subnet in var.subnets : subnet.collector_vpc_subnet_cidr if subnet.collector_vpc_subnet_region == element(split("/", each.value.id), 3)], 0), element(split("/", each.value.id), 3))
  })

  machine_type   = var.machine_type
  can_ip_forward = false

  disk {
    source_image = "zeekautomation/zeek-fluentd-golden-image-v1"
    auto_delete  = true
    boot         = true
  }

  # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform", "logging-write", "monitoring"]
  }

  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = each.value.id
  }

  depends_on = [google_compute_subnetwork.main, google_compute_network_peering.collector_vpc_network_peering]
}

# -------------------------------------------------------------- #
# HEALTH-CHECK
# -------------------------------------------------------------- #

resource "google_compute_health_check" "main" {
  name                = "http-health-check"
  description         = "Health check via http"
  timeout_sec         = 5
  check_interval_sec  = 10
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port = 80
  }
  depends_on = [google_compute_instance_template.main]
}

# -------------------------------------------------------------- #
# MANAGED-INSTANCE-GROUP
# -------------------------------------------------------------- #

resource "google_compute_region_instance_group_manager" "main" {
  for_each           = google_compute_instance_template.main
  name               = format("%s--%s", "collector-ig", element(split("--", element(split("/", each.value.id), 4)), 1))
  region             = format("%s", element(split("--", element(split("/", each.value.id), 4)), 1))
  base_instance_name = "mig-instance"

  version {
    instance_template = each.value.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.main.id
    initial_delay_sec = 90
  }

  depends_on = [google_compute_instance_template.main, google_compute_health_check.main]
}

# -------------------------------------------------------------- #
# AUTO-SCALER
# -------------------------------------------------------------- #

resource "google_compute_region_autoscaler" "main" {
  for_each = google_compute_region_instance_group_manager.main
  name     = format("%s--%s", "autoscaler", element(split("/", each.value.id), 3))
  region   = format("%s", element(split("/", each.value.id), 3))
  target   = each.value.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
  depends_on = [google_compute_region_instance_group_manager.main]
}

# -------------------------------------------------------------- #
# INTERNAL-LOAD-BALANCER
# -------------------------------------------------------------- #

resource "google_compute_region_backend_service" "main" {
  for_each              = google_compute_region_instance_group_manager.main
  name                  = format("%s--%s", "internal-loadbalancer", element(split("--", element(split("/", each.value.instance_group), 10)), 1))
  region                = format("%s", element(split("/", each.value.instance_group), 8))
  health_checks         = [google_compute_health_check.main.id]
  load_balancing_scheme = "INTERNAL"

  backend {
    group = each.value.instance_group
  }

  depends_on = [google_compute_region_instance_group_manager.main, google_compute_region_autoscaler.main]
}

# -------------------------------------------------------------- #
# FORWARDING-RULE
# -------------------------------------------------------------- #

resource "google_compute_forwarding_rule" "main" {
  for_each               = google_compute_region_backend_service.main
  name                   = format("%s--%s", "forwarding-rule", element(split("/", each.value.id), 3))
  region                 = format("%s", element(split("/", each.value.id), 3))
  load_balancing_scheme  = "INTERNAL"
  backend_service        = each.value.id
  all_ports              = true
  allow_global_access    = false
  is_mirroring_collector = true
  network                = google_compute_network.main.self_link
  subnetwork             = format("%s", element([for subnet in local.collector_subnet_ids : subnet if element(split("/", subnet), 3) == element(split("/", each.value.id), 3)], 0))
  depends_on             = [google_compute_region_backend_service.main]
}

# -------------------------------------------------------------- #
# PACKET-MIRRORING
# -------------------------------------------------------------- #

resource "google_compute_packet_mirroring" "main" {
  for_each = google_compute_forwarding_rule.main
  name     = format("%s--%s", "policy-mirror-to-collector", element(split("/", each.value.id), 3))
  region   = format("%s", element(split("/", each.value.id), 3))

  network {
    url = local.mirror_vpc_network_id
  }

  collector_ilb {
    url = each.value.id
  }

  mirrored_resources {
    dynamic "subnetworks" {
      for_each = lookup(local.packet_mirroring_mirror_subnet_sources, format("%s", element(split("/", each.value.id), 3)), [])
      content {
        url = subnetworks.value
      }
    }

    tags = lookup(local.packet_mirroring_mirror_tag_sources, format("%s", element(split("/", each.value.id), 3)), [])

    dynamic "instances" {
      for_each = lookup(local.packet_mirroring_mirror_instance_sources, format("%s", element(split("/", each.value.id), 3)), [])
      content {
        url = instances.value
      }
    }
  }

  filter {
    ip_protocols = var.ip_protocols
    direction    = var.direction
    cidr_ranges  = var.cidr_ranges
  }

  depends_on = [google_compute_forwarding_rule.main]
}
