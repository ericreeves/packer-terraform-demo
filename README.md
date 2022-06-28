## HCP Packer and Terraform Demo

This repository contains the Packer and Terraform HCL definitions for a basic end-to-end demonstration.

### Pre-Requisites
- Create or access an existing Terraform Cloud Organization with "Team & Governance Plan" features enabled.
- Create a Service Principal for the target Organization in portal.cloud.hashicorp.com, Access Control (IAM).
  - Capture the Client ID and Secret
- AWS
  - Create an AWS IAM User/Access Keys with the "AdministratorAccess" permission set in the target AWS account.
    - Capture the Access Key ID and Secret.
- GCP
  - Create a Service Account user with the Editor role, generate key in JSON.
    - Capture the key
- Create a Variable Set in Terraform Cloud containing the following Environment variables: 
  - HCP_CLIENT_ID
  - HCP_CLIENT_SECRET (sensitive)
  - AWS
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY (sensitive)
  - GCP
    - GOOGLE_CREDENTIALS (sensitive)
- Create the HCP-Packer Run Task in your Terraform Cloud Organization
  - Retrieve the "Endpoint URL" and "HMAC Key" from the HCP Packer / "Integrate with Terraform Cloud" page under portal.cloud.hashicorp.com

### Packer

- packer init .
- packer fmt .
- HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build 1-acme-base.pkr.hcl
- Assign image to "production" Channel
- HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build 2-acme-webapp.pkr.hcl
- Assign image to "production" Channel

### Terraform

- Edit terraform/terraform.tf and populate the Organization and Workspace names
- terraform init
- Assign the credentials Variable Set to the workspace, unless you created the Variable Set as organization-wide
- Assign HCP Packer Run Task to Workspace
- terraform plan
- terraform apply

### Revoke Image
- Revoke acme-webapp Iteration
- terraform plan
- terraform apply

### Update Image
- HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build 3-acme-base.pkr.hcl
- Assign image to "development" channel
- HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build 4-acme-webapp.pkr.hcl
- Assign image to "development" channel
- Modify terraform/web_app.tf, point to "development"
- terraform apply

### Various repositories were borrowed from to construct this demo.
- https://github.com/brokedba/terraform-examples
