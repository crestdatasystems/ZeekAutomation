# Basic Configurations
This example demonstrates how to use google zeek automation module with basic configurations.

## Usage

```tf
module "google_zeek_automation" {
  source                = "<link>/google_zeek_automation"
  gcp_project           = local.gcp_project_id
  service_account_email = data.google_client_openid_userinfo.main.email

  subnets               = var.subnets
  mirror_vpc_network    = var.mirror_vpc_network
  mirror_vpc_subnets    = var.mirror_vpc_subnets
}
```
Above variables can be set either by specifying it through [Environment Variables](https://www.terraform.io/docs/cli/config/environment-variables.html#tf_var_name) or setting it in `terraform.tfvars` file. Below is an example of how to set the variables in `terraform.tfvars` file.

```tf
  subnets = [
    {
      mirror_vpc_subnet_cidr      = ["{{subnet_cidr}}"]
      collector_vpc_subnet_cidr   = "{{subnet_cidr}}"
      collector_vpc_subnet_region = "{{region}}"
    },
  ]

  mirror_vpc_network = "{{mirror_vpc_network_id}}"

  mirror_vpc_subnets = {
    "{{region}}" = ["{{subnet_id}}"]
  }

```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket | Name of the bucket to store .tfstate file remotely. | `string` | n/a | yes |
| cidr\_ranges | IP CIDR ranges that apply as a filter on the source (ingress) or destination (egress) IP in the IP header. Only IPv4 is supported. | `list(string)` | `[]` | no |
| credentials | Path to a service account credentials file with rights to run the Google Zeek Automation. If this file is absent Terraform will fall back to Application Default Credentials. | `string` | `""` | no |
| direction | Direction of traffic to mirror. Default value: "BOTH" Possible values: ["INGRESS", "EGRESS", "BOTH"] | `string` | `"BOTH"` | no |
| ip\_protocols | Protocols that apply as a filter on mirrored traffic. Possible values: ["tcp", "udp", "icmp"] | `list(string)` | `[]` | no |
| mirror\_vpc\_instances | Mirror VPC Instances list to be mirrored. | `map(list(string))` | `{}` | no |
| mirror\_vpc\_network | Resource link of the network to add a peering to. | `string` | n/a | yes |
| mirror\_vpc\_subnets | Mirror VPC Subnets list to be mirrored. | `map(list(string))` | `{}` | no |
| mirror\_vpc\_tags | Mirror VPC Tags list to be mirrored. | `map(list(string))` | `{}` | no |
| subnets | The list of subnets being created | <pre>list(object({<br>    mirror_vpc_subnet_cidr      = list(string)<br>    collector_vpc_subnet_cidr   = string<br>    collector_vpc_subnet_region = string<br>  }))</pre> | n/a | yes |

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


To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure