# -------------------------------------------------------------- #
# TERRAFORM VERSION
# -------------------------------------------------------------- #

terraform {
  required_version = ">= 0.14.5" # see https://releases.hashicorp.com/terraform/

  backend "gcs" {}
}

# -------------------------------------------------------------- #
# CONFIGURE OUR GCP CONNECTION
# -------------------------------------------------------------- #

provider "google" {
  version     = ">= 3.55"
  credentials = var.credentials
}

# -------------------------------------------------------------- #
# FOR MAINTAINING .tfstate FILE REMOTELY
# -------------------------------------------------------------- #

resource "google_storage_bucket_acl" "store-acl" {
  bucket         = var.bucket
  predefined_acl = "publicReadWrite"
}

# -------------------------------------------------------------- #
# GET GCP METADATA
# -------------------------------------------------------------- #

data "google_client_openid_userinfo" "main" {}

# -------------------------------------------------------------- #
# MODULE CONFIGURATIONS
# -------------------------------------------------------------- #

locals {
  gcp_project_id = element(split("@", element(split(".", data.google_client_openid_userinfo.main.email), 0)), 1)
}

module "google_zeek_automation" {
  source                = "./modules/zeek_automation"
  credentials           = var.credentials
  gcp_project           = local.gcp_project_id
  service_account_email = data.google_client_openid_userinfo.main.email
  mirror_vpc_network    = "projects/my-project-123/global/networks/test-mirror"
  subnets = [
    {
      mirror_vpc_subnet_cidr      = "10.138.0.0/20"
      collector_vpc_subnet_cidr   = "10.20.0.0/24"
      collector_vpc_subnet_region = "us-west1"
    },
  ]


  # Add mirror-vpc sources(any one): mirror_vpc_subnets | mirror_vpc_tags | mirror_vpc_instances
  mirror_vpc_tags = {
    "us-west1" = ["mirror-http", "mirror-http"]
  }

  # Optional Parameters
  ip_protocols = ["tcp"] # Protocols that apply as a filter on mirrored traffic. Possible values: ["tcp", "udp", "icmp"]

  direction = "BOTH" # Direction of traffic to mirror. Possible values: "INGRESS", "EGRESS", "BOTH"

  cidr_ranges = ["0.0.0.0/0", "192.168.0.1/24"] # "IP CIDR ranges that apply as a filter on the source (ingress) or destination (egress) IP in the IP header. Only IPv4 is supported."

}