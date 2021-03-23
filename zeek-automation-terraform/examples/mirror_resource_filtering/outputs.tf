output "collector_vpc_network_id" {
  description = "The identifier of the VPC network with format projects/{{project}}/global/networks/{{name}}."
  value       = module.google_zeek_automation.collector_vpc_network_id
}

output "collector_vpc_subnets_ids" {
  description = "Sub Network identifier for the resource with format projects/{{project}}/regions/{{region}}/subnetworks/{{name}}"
  value       = module.google_zeek_automation.collector_vpc_subnets_ids
}

output "intance_template_ids" {
  description = "Instance Templates identifier for the resource with format projects/{{project}}/global/instanceTemplates/{{name}}"
  value       = module.google_zeek_automation.intance_template_ids
}

output "health_check_id" {
  description = "Health Check identifier for the resource with format projects/{{project}}/global/healthChecks/{{name}}"
  value       = module.google_zeek_automation.health_check_id
}

output "intance_group_ids" {
  description = "Managed Instance Group identifier for the resource with format {{disk.name}}"
  value       = module.google_zeek_automation.intance_group_ids
}

output "intance_groups" {
  description = "The full URL of the instance group created by the manager."
  value       = module.google_zeek_automation.intance_groups
}

output "autoscaler_ids" {
  description = "Autoscaler identifier for the resource with format projects/{{project}}/regions/{{region}}/autoscalers/{{name}}"
  value       = module.google_zeek_automation.autoscaler_ids
}

output "loadbalancer_ids" {
  description = "Internal Load Balancer identifier for the resource with format projects/{{project}}/regions/{{region}}/backendServices/{{name}}"
  value       = module.google_zeek_automation.loadbalancer_ids
}

output "forwarding_rule_ids" {
  description = "Forwarding Rule identifier for the resource with format projects/{{project}}/regions/{{region}}/forwardingRules/{{name}}"
  value       = module.google_zeek_automation.forwarding_rule_ids
}

output "packet_mirroring_policy_ids" {
  description = "Packet Mirroring Policy identifier for the resource with format projects/{{project}}/regions/{{region}}/packetMirrorings/{{name}}"
  value       = module.google_zeek_automation.packet_mirroring_policy_ids
}