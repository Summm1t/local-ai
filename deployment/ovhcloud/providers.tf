terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.48.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.1.0"
    }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

# OVH Public Cloud uses OpenStack API
# Note: The OpenStack provider requires a user that exists.
# If you are creating the project and user in the same run, 
# you MUST apply in two steps:
# 1. terraform apply -target=ovh_cloud_project_user.os_user -target=ovh_vrack_cloudproject.vcp
# 2. terraform apply
# This is due to a limitation in how Terraform initializes providers that depend on 
# resources that are not yet created. If you get a 'Username and UserID' error, 
# ensure you follow the two-step apply above.
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/"
  domain_name = "default"
  user_name   = var.os_user_name != "" ? var.os_user_name : (ovh_cloud_project_user.os_user.username != "" ? ovh_cloud_project_user.os_user.username : null)
  password    = var.os_password != "" ? var.os_password : (ovh_cloud_project_user.os_user.password != "" ? ovh_cloud_project_user.os_user.password : null)
  tenant_id   = local.service_name
}
