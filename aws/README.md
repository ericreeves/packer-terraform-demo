## HCP Packer and Terraform Demo in AWS

This repository contains the Packer and Terraform HCL definitions for a basic end-to-end demonstration in AWS.

### Pre-Requisites
- Create or access an existing Terraform Cloud Organization with "Team & Governance Plan" features enabled.
- Create an HCP Packer Registry with the "Plus" tier of service.
- Create a Service Principal for the target Organization in portal.cloud.hashicorp.com, Access Control (IAM).
  - Capture the Client ID and Secret
- Create a AWS IAM User and Access Keys with Admin privileges.
- Create a Variable Set in your Terraform Cloud Organization containing the following Environment variables: 
  - HCP_CLIENT_ID
  - HCP_CLIENT_SECRET (sensitive)
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY (sensitive)
  - AWS_DEFAULT_REGION
- Create an "HCP-Packer" Run Task in your Terraform Cloud Organization
  - Retrieve the "Endpoint URL" and "HMAC Key" from the HCP Packer / "Integrate with Terraform Cloud" page under portal.cloud.hashicorp.com
- Create a Workspace in Terraform Cloud
- Assign the "HCP-Packer" Run Task to the target Workspace and configure it as *Mandatory*.
- Look for all instances of the string "UPDATEME" within this repository, and populate your appropriate AWS Region and Terraform Hostname/Organization/Workspace.
  - ```grep UPDATEME .```

### Pre-Demo Tasks
It is best to execute these tasks prior to the start of the demo so you have a base configuration to start with and show in the HCP Packer / Terraform UI's.
#### Base Image Build

This build uses a AWS Ubuntu image and installs Apache2 to serve as our organization's base image.

- ```cd packer-1-base```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-base.pkr.hcl```
- Create a *production* Channel for *acme-base*, and assign the built Iteration to it.

#### Application Image Build

This build uses the production base image and deploys our application (creating an HTML file).

- ```cd packer-2-webapp```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-webapp.pkr.hcl```
- Create a *production* Channel for *acme-webapp*, and assign the built Iteration to it.

#### Initial Application Deployment

Use Terraform to deploy a simple VPC and our application image.

- ```cd terraform```
- ```terraform init```
- ```terraform plan```
- ```terraform apply```
- View cat pictures in the URL output by Terraform.

### Demo Tasks
This high level 

### Revoke Vulnerable Images

Oh no!  A zero-day Apache2 vulnerability has reared it's ugly head and it will never be patched!

- Revoke the *acme-base* Iteration.
- Revoke the *acme-webapp* Iteration.
- ```terraform plan```
- ```terraform apply```
- Observe that the *HCP-Runtask* prevented the Revoked image from being deployed.

### Build Updated Base Image

Let's replace Apache2 with Nginx to remediate the vulnerability.  We will build a new development base image so we can test the new image prior to a production deployment.

This build uses a AWS Ubuntu image and installs Nginx instead of Apache2.

- ```cd packer-3-base-update```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-base.pkr.hcl```
- Update the *production* channel for *acme-base* to point to this newly built Iteration.
- Observe that HCP Packer clearly shows parent/child ancestry as out-of-date.

### Build Updated Application Image

Let's build our step 2 web application again without making any changes to the HCL definition so we can consume the newly built production base image.

- ```cd packer-2-webapp```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-webapp.pkr.hcl```
- Update the *production* channel to point to this newly built Iteration.
- Observe that HCP Packer has resolved the out-of-date ancestry notifications.

### Deploy Updated Application Image

Use Terraform to deploy the new webapp application image.

- ```cd terraform```
- ```terraform plan```
- ```terraform apply```
- View cat pictures in the URL output by Terraform.
### Various repositories were borrowed from to construct this demo.
- https://github.com/brokedba/terraform-examples
