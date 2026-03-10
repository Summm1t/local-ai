module "network" {
  source     = "./modules/network"
  name       = "local-ai-network"
  project_id = var.project_id
  region     = var.region
}

module "security" {
  source      = "./modules/security"
  project_id  = var.project_id
  region      = var.region
  allowed_ips = var.allowed_ips
}

module "compute" {
  source              = "./modules/compute"
  project_id          = var.project_id
  region              = var.region
  flavor_name         = var.instance_flavor
  network_id          = module.network.network_id
  security_group_name = module.security.security_group_name
  ssh_public_key      = var.ssh_public_key
}

output "instance_ip" {
  value = module.compute.instance_ip
}
