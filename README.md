## HCP Packer and Terraform Demo

This repository contains the Packer and Terraform HCL definitions for a basic end-to-end demonstration in GCP.

### Pre-Requisites
- Create or access an existing Terraform Cloud Organization with "Team & Governance Plan" features enabled.
- Create an HCP Packer Registry with the "Plus" tier of service.
- Create a Service Principal for the target Organization in portal.cloud.hashicorp.com, Access Control (IAM).
  - Capture the Client ID and Secret
- Create a GCP Service Account user with the Editor role and generate a key in JSON.
  - Capture the key JSON as a string.
  - ```cat gcp-key.json | jq -c```
- Create a Variable Set in your Terraform Cloud Organization containing the following Environment variables: 
  - HCP_CLIENT_ID
  - HCP_CLIENT_SECRET (sensitive)
  - GOOGLE_CREDENTIALS (sensitive)
- Create an "HCP-Packer" Run Task in your Terraform Cloud Organization
  - Retrieve the "Endpoint URL" and "HMAC Key" from the HCP Packer / "Integrate with Terraform Cloud" page under portal.cloud.hashicorp.com
- Create a Workspace in Terraform Cloud
- Assign the "HCP-Packer" Run Task to the target Workspace and configure it as *Mandatory*.
- Look for all instances of the string "UPDATEME" within this repository, and populate your appropriate GCP Project ID and Terraform Hostname/Organization/Workspace.
  - ```grep UPDATEME .```

### Base Image Build

This build uses a GCE Ubuntu image and installs Apache2 to serve as our organization's base image.

- ```cd packer-1-base```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-base.pkr.hcl```
- Create a *production* Channel for *acme-base*, and assign the built Iteration to it.

### Application Image Build

This build uses the production base image and deploys our application (creating an HTML file).

- ```cd packer-2-webapp```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-webapp.pkr.hcl```
- Create a *production* Channel for *acme-webapp*, and assign the built Iteration to it.

### Initial Application Deployment

Use Terraform to deploy a simple VPC and our application image.

- ```cd terraform```
- ```terraform init```
- ```terraform plan```
- ```terraform apply```
- View cat pictures in the URL output by Terraform.

### Revoke Vulnerable Images

Oh no!  A zero-day Apache2 vulnerability has reared it's ugly head and it will never be patched!

- Revoke the *acme-base* Iteration.
- Revoke the *acme-webapp* Iteration.
- ```terraform plan```
- ```terraform apply```
- Observe that the *HCP-Runtask* prevented the Revoked image from being deployed.

### Build Development Base Image

Let's replace Apache2 with Nginx to remediate the vulnerability.  We will build a new development base image so we can test the new image prior to a production deployment.

This build uses a GCE Ubuntu image and installs Nginx instead of Apache2.

- ```cd packer-3-base-update```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-base.pkr.hcl```
- Create a *development* Channel for *acme-base*, and assign the built Iteration to it.

### Build Development Application Image

This build uses the new development base image and deploys our application (creating an HTML file).

- ```cd packer-4-webapp-update```
- ```packer init .```
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-webapp.pkr.hcl```
- Create a *development* Channel for *acme-webapp*, and assign the built Iteration to it.

### Deploy Updated Development Application Image

Use Terraform to deploy the new development application image.

- ```cd terraform```
- Open web_app.tf in an editor.
  - Set Variable *hcp_channel* to *development*
- ```terraform plan```
- ```terraform apply```

### Promote Development Images to Production

Testing has been completed and it is time to promote the development base image to production.

(This stage is not represented in the demo code.)

- Update the *production* Iteration for *acme-base*, and assign the tested Iteration to it.
- Update *acme-webapp.pkr.hcl* and set *hcp_channel_base* to *production*.
- ```HCP_PACKER_BUILD_FINGERPRINT="$(date +%s)" packer build acme-webapp.pkr.hcl```
- Update *web_app.tf* and set *hcp_channel* to *production*.
- ```terraform plan```
- ```terraform apply```
- Profit!

### Various repositories were borrowed from to construct this demo.
- https://github.com/brokedba/terraform-examples
