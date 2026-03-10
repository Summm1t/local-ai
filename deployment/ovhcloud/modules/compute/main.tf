variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "flavor_name" {
  description = "Flavor name"
  type        = string
}

variable "network_id" {
  description = "Private network ID"
  type        = string
}

variable "security_group_name" {
  description = "Security group name"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

resource "ovh_cloud_project_user" "user" {
  service_name = var.project_id
  description  = "User for OpenStack"
  role_name    = "compute_operator"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "local-ai-keypair"
  public_key = var.ssh_public_key
  region     = var.region
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "local-ai-gpu"
  region          = var.region
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [var.security_group_name]

  # Debian 12 (latest stable)
  image_name = "Debian 12"

  network {
    name = "Ext-Net" # Public network
  }

  network {
    uuid = var.network_id
  }

  user_data = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - git
      - nvme-cli

    runcmd:
      # Install Docker
      - curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      - apt-get update
      - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

      # Install NVIDIA Container Toolkit
      - curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
      - curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
      - apt-get update
      - apt-get install -y nvidia-container-toolkit
      - nvidia-ctk runtime configure --runtime=docker
      - systemctl restart docker

      # Prepare application
      - mkdir -p /opt/local-ai
      - git clone https://github.com/coleam00/local-ai-packaged.git /opt/local-ai
      - cd /opt/local-ai
      - cp .env.example .env
      # Note: User will need to fill in the .env with their secrets

  EOF
}

output "instance_ip" {
  value = openstack_compute_instance_v2.instance.network[0].fixed_ip_v4
}
