# Google Zeek Automation Submodule

This module simplifies the deployment of Zeek so GCP customers can feed raw packets from VPC Packet Mirroring and produce rich security telemetry for threat detection and investigation in our Chronicle Security Platform.

## Compatibility

This module is meant for use with Terraform 0.14 or above.


## Usage

```tf
data "google_client_openid_userinfo" "main" {}

locals {
  gcp_project_id = element(split("@ - element(split(". - data.google_client_openid_userinfo.main.email), 0)), 1)
}

module "zeek_automation" {
  source           = "<link>/modules/zeek_automation"
  
  credentials           = "credentials.json"
  gcp_project           = local.gcp_project_id
  service_account_email = data.google_client_openid_userinfo.main.email

  subnets = [
    {
      mirror_vpc_subnet_cidr      = "10.138.0.0/20"
      collector_vpc_subnet_cidr   = "10.11.0.0/24"
      collector_vpc_subnet_region = "us-west1"
    },
  ]

  mirror_vpc_network = "projects/my-project-123/global/networks/test-mirror"

  mirror_vpc_subnets = {
    "us-west1" = ["projects/my-project-123/regions/us-west1/subnetworks/subnet-01"]
  }

}
```

Then perform the following commands on the root folder:
- `terraform init -backend-config='backend.tfvars'` to get the plugins
- `terraform plan -var-file='backend.tfvars'` to see the infrastructure plan
- `terraform apply -var-file='backend.tfvars'` to apply the infrastructure build
- `terraform destroy -var-file='backend.tfvars'` to destroy the built infrastructure


## Requirements
Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Terraform is [installed](#software-dependencies) on the machine where Terraform is executed.
2. The Service Account you execute the module with has the right [permissions](#configure-a-service-account).
3. The Compute Engine APIs are [active](#enable-apis) on the project you will launch the infrastructure on.
4. User must create a GCS Bucket and its name should be given as an input to `backend.tfvars` file.


## Software Dependencies

### Terraform and Plugins
- [Terraform](https://www.terraform.io/downloads.html) 0.14
- [Terraform Provider for GCP][terraform-provider-google] v3.55


### Configure a Service Account
In order to execute this module you must have a Service Account with the following project roles:
- Service Account User - `roles/iam.serviceAccountUser`
- Service Account Token Creator - `roles/iam.serviceAccountTokenCreator`
- Compute Admin - `roles/compute.admin`
- Compute Network Admin - `roles/compute.networkAdmin`
- Compute Packet Mirroring User - `roles/compute.packetMirroringUser`
- Compute Packet Mirroring Admin - `roles/compute.packetMirroringAdmin`
- Logs Writer - `roles/logging.logWriter`
- Monitoring Metric Writer - `roles/monitoring.metricWriter`
- Storage Admin - `roles/storage.admin`


### Enable APIs
In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

- Compute Engine API - `compute.googleapis.com`
- Service Usage API - `serviceusage.googleapis.com`
- Identity and Access Management (IAM) API - `iam.googleapis.com`
- Cloud Resource Manager API - `cloudresourcemanager.googleapis.com`
- Cloud Logging API - `logging.googleapis.com`
- Cloud Monitoring API - `monitoring.googleapis.com`
- Cloud Storage API - `storage.googleapis.com`


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| credentials | GCP credentials file | `string` | n/a | yes |
| gcp\_project | GCP Project Id | `string` | n/a | yes |
| mirror\_vpc\_instances | Mirror VPC Instances list to be mirrored. | `map(list(string))` | `{}` | no |
| mirror\_vpc\_network | Resource link of the network to add a peering to. | `string` | n/a | yes |
| mirror\_vpc\_subnets | Mirror VPC Subnets list to be mirrored. | `map(list(string))` | `{}` | no |
| mirror\_vpc\_tags | Mirror VPC Tags list to be mirrored. | `map(list(string))` | `{}` | no |
| service\_account\_email | User's Service Account Email. | `string` | n/a | yes |
| subnets | The list of subnets being created | `list(map(string))` | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| autoscaler\_ids | Autoscaler identifier for the resource with format projects/{{project}}/regions/{{region}}/autoscalers/{{name}} |
| collector\_vpc\_network\_id | The identifier of the VPC network with format projects/{{project}}/global/networks/{{name}}. |
| collector\_vpc\_subnets\_ids | Sub Network identifier for the resource with format projects/{{project}}/regions/{{region}}/subnetworks/{{name}} |
| forwarding\_rule\_ids | Forwarding Rule identifier for the resource with format projects/{{project}}/regions/{{region}}/forwardingRules/{{name}} |
| health\_check\_id | Health Check identifier for the resource with format projects/{{project}}/global/healthChecks/{{name}} |
| intance\_group\_ids | Managed Instance Group identifier for the resource with format {{disk.name}} |
| intance\_groups | The full URL of the instance group created by the manager. |
| intance\_template\_ids | Instance Templates identifier for the resource with format projects/{{project}}/global/instanceTemplates/{{name}} |
| loadbalancer\_ids | Internal Load Balancer identifier for the resource with format projects/{{project}}/regions/{{region}}/backendServices/{{name}} |
| packet\_mirroring\_policy\_ids | Packet Mirroring Policy identifier for the resource with format projects/{{project}}/regions/{{region}}/packetMirrorings/{{name}} |



[terraform-provider-google]: https://github.com/terraform-providers/terraform-provider-google