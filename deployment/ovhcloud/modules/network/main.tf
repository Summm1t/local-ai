terraform {
  required_providers {
    ovh = {
      source = "ovh/ovh"
    }
  }
}

variable "name" {
  description = "Name of the network"
  type        = string
}

variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

resource "ovh_cloud_project_network_private" "private_net" {
  service_name = var.project_id
  name         = var.name
  regions      = [var.region]
}

resource "ovh_cloud_project_network_private_subnet" "subnet" {
  service_name = var.project_id
  network_id   = ovh_cloud_project_network_private.private_net.id
  region       = var.region
  start        = "192.168.0.10"
  end          = "192.168.0.250"
  network      = "192.168.0.0/24"
  dhcp         = true
}

output "network_id" {
  value = ovh_cloud_project_network_private.private_net.id
}
