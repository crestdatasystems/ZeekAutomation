project_id      = attribute('project_id')
network_name    = attribute('network_name')
mirror_vpc_name = attribute('mirror_vpc_name')
region          = attribute('region')

control "gcp" do
  title "Google Cloud configuration"
  describe google_compute_network(
    project: project_id,
    name: network_name
  ) do
    it { should exist }
  end

  describe google_compute_subnetwork(
    project: project_id,
    name: "subnet-01",
    region: "us-central1"
  ) do
    it { should exist }
  end

  describe google_compute_firewalls(project: project_id) do
    its('firewall_names') { should include "#{network_name}-rule-allow-ingress" }
    its('firewall_names') { should include "#{network_name}-rule-allow-health-check" }
    its('firewall_names') { should include "#{mirror_vpc_name}-rule-allow-egress" }
  end

  describe google_compute_forwarding_rule(
    project: project_id, 
    region: region, 
    name: "forwarding-rule--us-central1"
    ) do
    its('load_balancing_scheme') { should match "INTERNAL" }
  end

  describe google_compute_health_check(
    project: project_id,
    region: region, 
    name: "http-health-check"
    ) do
      it { should exist }
    end

  describe google_compute_instance_template(
    project: project_id,
    region: region, 
    name: "collector-it--us-central1"
    ) do
      it { should exist }
    end

  describe google_compute_region_instance_group_manager(
    project: project_id,
    region: region, 
    name: "collector-ig--us-central1"
    ) do
      it { should exist }
    end
end