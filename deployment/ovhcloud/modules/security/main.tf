terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "allowed_ips" {
  description = "Allowed IPs for SSH"
  type        = list(string)
}

# Create a security group using OpenStack provider
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "local-ai-secgroup"
  description = "Security group for Local AI"
  region      = var.region
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  count             = length(var.allowed_ips)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.allowed_ips[count.index]
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  region            = var.region
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  region            = var.region
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  region            = var.region
}

output "security_group_name" {
  value = openstack_networking_secgroup_v2.secgroup.name
}
