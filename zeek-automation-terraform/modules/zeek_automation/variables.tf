# -------------------------------------------------------------- #
# PROJECT variables
# -------------------------------------------------------------- #

variable "credentials" {
  description = "GCP credentials file"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project Id"
  type        = string
}

# -------------------------------------------------------------- #
# VPC module variables
# -------------------------------------------------------------- #

variable "vpc_name" {
  description = "Portion of name to be generated for the VPC network."
  type        = string
  default     = "poc-collector-vpc"
}

variable "vpc_description" {
  description = "The description of the VPC Network."
  type        = string
  default     = "This is collector VPC network."
}

variable "vpc_routing_mode" {
  description = "Routing mode of the VPC. A 'GLOBAL' routing mode can have adverse impacts on load balancers. Prefer 'REGIONAL'."
  type        = string
  default     = "REGIONAL"
}

variable "auto_create_subnetworks" {
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in 'custom subnet mode' so the user can explicitly connect subnetwork resources."
  type        = bool
  default     = false
}

variable "delete_default_internet_gateway_routes" {
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  type        = bool
  default     = false
}

variable "mtu" {
  description = "The network MTU. Must be a value between 1460 and 1500 inclusive. If set to 0 (meaning MTU is unset), the network will default to 1460 automatically."
  type        = number
  default     = 0
}

variable "private_ip_google_access" {
  description = "When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access."
  type        = bool
  default     = true
}

variable "subnets" {
  type        = list(map(string))
  description = "The list of subnets being created"
}

# -------------------------------------------------------------- #
# FIREWALL-RULE module variables
# -------------------------------------------------------------- #

variable "mirror_vpc_network" {
  description = "Resource link of the network to add a peering to."
  type        = string
}

# -------------------------------------------------------------- #
# VPC-PEERING module variables
# -------------------------------------------------------------- #

variable "export_peer_custom_routes" {
  description = "Export custom routes to local network from peer network."
  type        = bool
  default     = false
}

variable "export_local_custom_routes" {
  description = "Export custom routes to peer network from local network."
  type        = bool
  default     = false
}

# -------------------------------------------------------------- #
# INSTANCE-TEMPLATE module variables
# -------------------------------------------------------------- #

variable "template_description" {
  description = "This is instance template description."
  type        = string
  default     = "This instance template is used to create zeek-fluentd instances."
}

variable "machine_type" {
  description = "This is instance template machine type."
  type        = string
  default     = "e2-medium"
}

variable "service_account_email" {
  description = "User's Service Account Email."
  type        = string
}

# -------------------------------------------------------------- #
# PACKET-MIRRORING module variables
# -------------------------------------------------------------- #

variable "mirror_vpc_subnets" {
  description = "Mirror VPC Subnets list to be mirrored."
  type        = map(list(string))
  default     = {}
}

variable "mirror_vpc_tags" {
  description = "Mirror VPC Tags list to be mirrored."
  type        = map(list(string))
  default     = {}
}

variable "mirror_vpc_instances" {
  description = "Mirror VPC Instances list to be mirrored."
  type        = map(list(string))
  default     = {}
}

variable "ip_protocols" {
  description = "Protocols that apply as a filter on mirrored traffic. Possible values: [\"tcp\", \"udp\", \"icmp\"]"
  type        = list(string)
  default     = ["tcp"]
}

variable "direction" {
  description = "Direction of traffic to mirror. Default value: \"BOTH\" Possible values: [\"INGRESS\", \"EGRESS\", \"BOTH\"]"
  type        = string
  default     = "BOTH"
}

variable "cidr_ranges" {
  description = "IP CIDR ranges that apply as a filter on the source (ingress) or destination (egress) IP in the IP header. Only IPv4 is supported."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

