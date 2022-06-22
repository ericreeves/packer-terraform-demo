## HCP Packer and Terraform Demo

This repository contains the Packer and Terraform HCL definitions for a basic end-to-end demonstration.


### Pre-Requisites
- Create a Service Principal for the target Organization in portal.cloud.hashicorp.com, Access Control (IAM)
- Create a Variable Set containing the following Environment variables: 
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY (sensitive)
  - HCP_CLIENT_ID
  - HCP_CLIENT_SECRET (sensitive)
- Create the HCP-Packer Run Task in your Terraform Cloud Organization
  - Retrieve the "Endpoint URL" and "HMAC Key" from the HCP Packer page under portal.cloud.hashicorp.com

### Packer

- packer init .
- packer fmt .
- packer build ubuntu.pkr.hcl
- Create Channel in HCP Packer
- Assign image to Channel

### Terraform

- Edit terraform/terraform.tf and populate the Organization and Workspace names
- terraform init
- Assign the credentials Variable Set to the workspace, unless you created the Variable Set as organization-wide
- Assign HCP Packer Run Task to Workspace
- terraform plan
- terraform apply

### Revoke Image
- Edit Revocation for 1 minute in the future
- terraform plan
- terraform apply
- Remove Revocation
- terraform apply

### Update Image
- Modify deploy-app.sh
- Git commit changes
- packer build ubuntu.pkr.hcl
- Update Channel to latest image
- terraform apply
