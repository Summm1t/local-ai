variable "ovh_application_key" {
  description = "OVH Application Key"
  type        = string
}

variable "ovh_application_secret" {
  description = "OVH Application Secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH Consumer Key"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "The name of the Public Cloud project"
  type        = string
  default     = "localllm"
}

variable "region" {
  description = "OVH Region"
  type        = string
  default     = "GRA9"
}

variable "project_id" {
  description = "OVH Public Cloud Project ID (if already existing)"
  type        = string
  default     = null
}

variable "os_user_name" {
  description = "OpenStack user name (leave empty to use created user)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "os_password" {
  description = "OpenStack user password (leave empty to use created user)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "instance_flavor" {
  description = "The instance flavor (size)"
  type        = string
  default     = "t1-45" # A10 GPU (24GB VRAM) for testing or L4 (24GB)
}

variable "ssh_public_key" {
  description = "Public SSH key for instance access"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IPs for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "existing_security_group_name" {
  description = "Name of an existing security group to use (if null, a new one will be created)"
  type        = string
  default     = null
}

variable "vrack_id" {
  description = "The vRack ID to attach the project to (leave null if a new one should be created or already exists)"
  type        = string
  default     = null
}
