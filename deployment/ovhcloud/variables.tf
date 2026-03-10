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

variable "region" {
  description = "OVH Region"
  type        = string
  default     = "GRA9"
}

variable "project_id" {
  description = "OVH Public Cloud Project ID"
  type        = string
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
