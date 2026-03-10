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

variable "existing_security_group_name" {
  description = "Name of an existing security group to use (if null, a new one will be created)"
  type        = string
  default     = null
}

# Create a security group using OpenStack provider
resource "openstack_networking_secgroup_v2" "secgroup" {
  count       = var.existing_security_group_name == null ? 1 : 0
  name        = "local-ai-secgroup"
  description = "Security group for Local AI"
  region      = var.region
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  count             = var.existing_security_group_name == null ? length(var.allowed_ips) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.allowed_ips[count.index]
  security_group_id = openstack_networking_secgroup_v2.secgroup[0].id
  region            = var.region
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  count             = var.existing_security_group_name == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup[0].id
  region            = var.region
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  count             = var.existing_security_group_name == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup[0].id
  region            = var.region
}

output "security_group_name" {
  value = var.existing_security_group_name != null ? var.existing_security_group_name : openstack_networking_secgroup_v2.secgroup[0].name
}
