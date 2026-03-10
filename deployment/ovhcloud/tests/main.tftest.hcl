
variables {
  ovh_application_key    = "test_key"
  ovh_application_secret = "test_secret"
  ovh_consumer_key       = "test_consumer"
  project_id             = "test_project"
  project_name           = "localllm-test"
  os_user_name           = "test_os_user"
  os_password            = "test_os_password"
  ssh_public_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8"
}

run "validate_network" {
  command = plan

  assert {
    condition     = module.network.network_id != ""
    error_message = "Network ID should not be empty"
  }
}

run "validate_security" {
  command = plan

  assert {
    condition     = length(module.security.security_group_name) > 0
    error_message = "Security group name should be set"
  }
}

run "validate_compute_flavor" {
  command = plan

  assert {
    condition     = var.instance_flavor == "t1-45" || var.instance_flavor == "hgr-gpu-1-a100"
    error_message = "Selected flavor is not a standard GPU flavor for this deployment"
  }
}
