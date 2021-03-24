# -------------------------------------------------------------- #
# Get GCP metadata
# -------------------------------------------------------------- #

data "google_client_openid_userinfo" "main" {}

# -------------------------------------------------------------- #
# Module configurations
# -------------------------------------------------------------- #

locals {
  gcp_project_id = element(split("@", element(split(".", data.google_client_openid_userinfo.main.email), 0)), 1)
}

module "google_zeek_automation" {
  source                = "../../../modules/zeek_automation"
  credentials           = "../../../credentials.json"
  gcp_project           = local.gcp_project_id
  service_account_email = data.google_client_openid_userinfo.main.email

  subnets = [
    {
      mirror_vpc_subnet_cidr      = ["10.128.0.0/20"]
      collector_vpc_subnet_cidr   = "10.10.0.0/24"
      collector_vpc_subnet_region = "us-central1"
    },
    {
      mirror_vpc_subnet_cidr      = ["10.138.0.0/20"]
      collector_vpc_subnet_cidr   = "10.20.0.0/24"
      collector_vpc_subnet_region = "us-west1"
    },
  ]

  mirror_vpc_network = "projects/<your_project_id>/global/networks/<your_network_id>"

  mirror_vpc_subnets = {
    "us-central1" = ["projects/<your_project_id>/regions/<your_region>/subnetworks/<your_subnetwork_id>"]
    "us-west1"    = ["projects/<your_project_id>/regions/<your_region>/subnetworks/<your_subnetwork_id>"]
  }

}