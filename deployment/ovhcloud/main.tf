# Create the Public Cloud project if not provided
data "ovh_me" "myaccount" {}

data "ovh_order_cart" "mycart" {
  ovh_subsidiary = data.ovh_me.myaccount.ovh_subsidiary
}

data "ovh_order_cart_product_plan" "cloud" {
  cart_id        = data.ovh_order_cart.mycart.id
  price_capacity = "renew"
  product        = "cloud"
  plan_code      = "project.2018"
}

resource "ovh_cloud_project" "project" {
  count       = var.project_id == null ? 1 : 0
  description = var.project_name
  ovh_subsidiary = data.ovh_order_cart.mycart.ovh_subsidiary

  plan {
    duration     = data.ovh_order_cart_product_plan.cloud.selected_price.0.duration
    plan_code    = data.ovh_order_cart_product_plan.cloud.plan_code
    pricing_mode = data.ovh_order_cart_product_plan.cloud.selected_price.0.pricing_mode
  }
}

# Create a vRack if one is not provided
resource "ovh_vrack" "vrack" {
  count          = var.vrack_id == null ? 1 : 0
  description    = "vRack for ${var.project_name}"
  ovh_subsidiary = data.ovh_me.myaccount.ovh_subsidiary
  plan {
    duration     = "P1M"
    plan_code    = "vrack"
    pricing_mode = "default"
  }
}

locals {
  service_name = var.project_id != null ? var.project_id : (length(ovh_cloud_project.project) > 0 ? ovh_cloud_project.project[0].project_id : null)
  vrack_id     = var.vrack_id != null ? var.vrack_id : (length(ovh_vrack.vrack) > 0 ? ovh_vrack.vrack[0].service_name : null)
}

# Attach vRack to Public Cloud project
resource "ovh_vrack_cloudproject" "vcp" {
  service_name = local.vrack_id
  project_id   = local.service_name
}

# Wait for the project to be ready if we are creating it
resource "null_resource" "wait_for_project" {
  count = length(ovh_cloud_project.project) > 0 ? 1 : 0
  
  provisioner "local-exec" {
    command = "sleep 60" # OVH can be slow, 60s is safer to reach 'ok' status
  }
}

# Create OpenStack user for the project
resource "ovh_cloud_project_user" "os_user" {
  service_name = local.service_name
  description  = "Terraform OpenStack User"
  role_name    = "administrator" # Administrator role is needed for full project management
  
  depends_on = [null_resource.wait_for_project]
}

module "network" {
  source     = "./modules/network"
  name       = "local-ai-network"
  project_id = local.service_name
  region     = var.region

  depends_on = [ovh_vrack_cloudproject.vcp]
}

module "security" {
  source                       = "./modules/security"
  project_id                   = local.service_name
  region                       = var.region
  allowed_ips                  = var.allowed_ips
  existing_security_group_name = var.existing_security_group_name

  depends_on = [ovh_cloud_project_user.os_user]
}

module "compute" {
  source              = "./modules/compute"
  project_id          = local.service_name
  region              = var.region
  flavor_name         = var.instance_flavor
  network_id          = module.network.network_id
  security_group_name = module.security.security_group_name
  ssh_public_key      = var.ssh_public_key

  depends_on = [ovh_cloud_project_user.os_user]
}

output "instance_ip" {
  value = module.compute.instance_ip
}

output "openstack_username" {
  value = ovh_cloud_project_user.os_user.username
}

output "openstack_password" {
  value     = ovh_cloud_project_user.os_user.password
  sensitive = true
}

output "project_id" {
  value = local.service_name
}
