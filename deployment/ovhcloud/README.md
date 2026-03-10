# OVHCloud Deployment for Local AI

This directory contains Terraform scripts to deploy the Local AI project on OVHCloud.

## Architecture

The deployment consists of:
- A private network and subnet for internal communication.
- A security group (firewall) opening only ports 22 (SSH), 80 (HTTP), and 443 (HTTPS).
- A GPU-enabled instance (e.g., NVIDIA A10/L4) to run 30B LLMs.
- Automated installation of Docker and NVIDIA Container Toolkit via cloud-init.

## Prerequisites

1.  **OVHCloud Account**: You need an active OVHCloud account and a Public Cloud project.
2.  **API Credentials**: Create an Application Key, Application Secret, and Consumer Key at [OVH API Console](https://eu.api.ovh.com/createToken/).
3.  **Terraform**: Installed locally.

## Usage

1.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

2.  **Set Variables**:
    Create a `terraform.tfvars` file with your credentials and project details:
    ```hcl
    ovh_application_key    = "your_app_key"
    ovh_application_secret = "your_app_secret"
    ovh_consumer_key       = "your_consumer_key"
    project_id             = "your_ovh_project_id"
    ssh_public_key         = "ssh-rsa ..."
    allowed_ips           = ["your_ip_address/32"] # For SSH access
    ```

3.  **Review and Apply**:
    ```bash
    terraform plan
    terraform apply
    ```

## Testing

Run the included Terraform tests:
```bash
terraform test
```

4.  **Complete the Setup**:
    Once the instance is up (it may take a few minutes for cloud-init to finish), SSH into it:
    ```bash
    ssh debian@<instance_ip>
    ```
    The project is cloned in `/opt/local-ai`. You need to finish the `.env` configuration:
    ```bash
    cd /opt/local-ai
    nano .env
    ```
    Alternatively, use the provided script to generate random secrets:
    ```bash
    ./deployment/ovhcloud/scripts/setup-env.sh
    ```
    Then start the services:
    ```bash
    docker compose up -d --profile gpu-nvidia
    ```

## Sizing for 30B LLMs

The default instance flavor is `t1-45` (NVIDIA A10 with 24GB VRAM). 
- For 30B models (quantized to 4-bit), 24GB VRAM is typically sufficient for 8k-16k context.
- For "quite big context" (32k+), consider higher flavors like `t2-180` (A100 with 40GB/80GB VRAM) if available in your region.

## Cloud Independence

The scripts are modular. To add another cloud provider (e.g., AWS), you can create a parallel `deployment/aws` directory and implement similar modules for VPC, EC2, and Security Groups. The cloud-init script can be shared or adapted for the new provider's base images.
