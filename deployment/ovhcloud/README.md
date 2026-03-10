# OVHCloud Deployment for Local AI

This directory contains Terraform scripts to deploy the Local AI project on OVHCloud.

## Architecture

The deployment consists of:

- A private network and subnet for internal communication.
- A security group (firewall) opening only ports 22 (SSH), 80 (HTTP), and 443 (HTTPS).
- A GPU-enabled instance (e.g., NVIDIA A10/L4) to run 30B LLMs.
- Automated installation of Docker and NVIDIA Container Toolkit via cloud-init.

## Prerequisites

1. **OVHCloud Account**: You need an active OVHCloud account.
2. **API Credentials**: Create an Application Key, Application Secret, and Consumer Key
   at [OVH API Console](https://eu.api.ovh.com/createToken/).
   The following rights (REST API calls) are required at minimum:
    - `GET /auth/details`
    - `GET /cloud/project`
    - `POST /cloud/project`
    - `GET /cloud/project/*`
    - `POST /cloud/project/*`
    - `DELETE /cloud/project/*`
    - `GET /cloud/project/*/vrack`
    - `POST /cloud/project/*/vrack`
    - `GET /vrack`
    - `GET /vrack/*`
    - `POST /vrack/*`
    - `GET /cloud/project/*/role`
    - `GET /order/*`

3. **Terraform**: Installed locally.

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Set Variables**:
   Create a `terraform.tfvars` file. You can either provide an existing `project_id` or let
   Terraform create a new one:

   **Option A: Create new project and user (Recommended)**
   ```hcl
   ovh_application_key    = "your_app_key"
   ovh_application_secret = "your_app_secret"
   ovh_consumer_key       = "your_consumer_key"
   project_name           = "local-llm"
   vrack_id               = "your_vrack_id" # Optional: Leave out to create a new vRack
   ssh_public_key         = "ssh-rsa ..."
   allowed_ips           = ["your_ip_address/32"]
   ```
   *Note: When creating a project and user for the first time, you MUST apply in two steps because the
   OpenStack provider needs an existing user to authenticate:*
   1. `terraform apply -target=ovh_cloud_project_user.os_user -target=ovh_vrack_cloudproject.vcp -auto-approve`
   2. `terraform apply -auto-approve`

   **Option B: Use existing project**
   ```hcl
   ovh_application_key    = "your_app_key"
   ovh_application_secret = "your_app_secret"
   ovh_consumer_key       = "your_consumer_key"
   project_id             = "your_existing_project_id"
   os_user_name           = "your_openstack_username"
   os_password            = "your_openstack_password"
   vrack_id               = "your_vrack_id" # Required if your project needs a specific vRack
   ssh_public_key         = "ssh-rsa ..."
   allowed_ips           = ["your_ip_address/32"]
   ```

3. **Review and Apply**:
   ```bash
   terraform plan
   terraform apply
   ```

## Testing

Run the included Terraform tests:

```bash
terraform test
```

4. **Complete the Setup**:
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

## Troubleshooting

### OverQuota: Quota exceeded for resources: ['security_group']

If you see an error like `OverQuota: Quota exceeded for resources: ['security_group']`, it means
your OVHCloud project has reached the limit of security groups allowed in the region.

You can:

1. **Delete unused security groups** in the OVH Manager (Public Cloud -> Network -> Security
   Groups).
2. **Use an existing security group** by adding `existing_security_group_name = "your_sg_name"` to
   your `terraform.tfvars`. You can find them in the "Horizon" interface.
3. **Request a quota increase** from OVHCloud support.

## Sizing for 30B LLMs

The default instance flavor is `t1-45` (NVIDIA A10 with 24GB VRAM).

- For 30B models (quantized to 4-bit), 24GB VRAM is typically sufficient for 8k-16k context.
- For "quite big context" (32k+), consider higher flavors like `t2-180` (A100 with 40GB/80GB VRAM)
  if available in your region.

## Cloud Independence

The scripts are modular. To add another cloud provider (e.g., AWS), you can create a parallel
`deployment/aws` directory and implement similar modules for VPC, EC2, and Security Groups. The
cloud-init script can be shared or adapted for the new provider's base images.
