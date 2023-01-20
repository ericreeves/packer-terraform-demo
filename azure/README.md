# Automating Azure Image Pipelines with HCP Packer

These configurations demonstrate using Packer to build customized Azure VM images which are published to the HCP Packer hosted image registry and consumed by a Terraform provisioning workflow. Image ancestry tracking in HCP Packer is also demonstrated by building a parent/child image pipeline.

## Requirements

- An Azure subscription with an existing Resource Group where builds will occur and images will be stored, including a Compute Gallery pre-populated as described in the Notes section below
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
- An [HCP Packer](https://cloud.hashicorp.com/products/packer) image registry (free for up to 10 images)
- [Packer](https://www.packer.io/) 1.7.7 or newer
- [Terraform](https://www.terraform.io/) 1.0 or newer

## Contents

- `0-terraform-pre` - Terraform configuration to create the required Resource Group and Shared Image Gallery resources in Azure
- `1-packer-ubuntu20-base` - the base or "parent" image
- `2-packer-ubuntu20-nginx` - "child" image which derives from the base to add Nginx
- `3-terraform-deploy-hashicafe` - a Terraform configuration to deploy the image as a simple webapp

## Notes

The Packer builds will create a managed image and also publish to an [Azure compute gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/azure-compute-gallery), which must be located in the same Resource Group as your images.

The Resource Group and compute gallery resources are created by the Terraform code in `0-terraform-pre`.

The compute gallery can be disabled by removing the `azurerm_shared_image_gallery` and `azurerm_shared_image` resources from the `0-terraform-pre` configuration, and the `destination_shared_image_gallery` block from the Packer builds; it's included to demonstrate the capability but isn't critical to the workflow.

## Steps

1. Sign in to your Azure account with `az login`.

2. Make a copy of the `packer.auto.pkrvars.hcl.example` and `terraform.auto.tfvars.example` files without the `.example` suffix, and fill in your desired values. See each variables file for descriptions.

3. Update `terraform.tf` to include appropriate `hostname`, `organization`, and `workspace` configuation for Teraform Cloud or Terraform Enterprise.

4. Run the `0-terraform-pre` Terraform configuration.

```pushd 0-terraform-pre && terraform init && terraform apply -auto-approve && popd```

5. Run the `1-hcp-packer-ubuntu20-base` build, then in HCP Packer assign the new iteration in the **ubuntu20-base** bucket to a channel named "development".

```pushd 1-hcp-packer-ubuntu20-base && packer init . && packer build . && popd```

```../scripts/hcp-par-helper.sh channels create ubuntu20-base development```

```../scripts/hcp-par-helper.sh channels set-iteration ubuntu20-base development <iteration ID returned from build>```

6. Run the `2-hcp-packer-ubuntu20-nginx` build, then assign the new iteration in the **ubuntu20-nginx** bucket to a channel named "development".

```pushd 2-hcp-packer-ubuntu20-nginx && packer init . && packer build . && popd```

```../scripts/hcp-par-helper.sh channels create ubuntu20-nginx development```

```../scripts/hcp-par-helper.sh channels set-iteration ubuntu20-nginx development <iteration ID returned from build>```

7. Run the `3-teraform-deploy-webserver` Terraform configuration.

```pushd 3-terraform-deploy-webserver && terraform init && terraform apply -auto-approve && popd```

## Credit

A majority of this repository was directly taken from [Dan Barr's Excellent HCP Packer Azure Repository](https://github.com/danbarr/hcp-packer-azure).  Dan used this code in the [DevOps Lab](https://learn.microsoft.com/en-us/shows/devops-lab/?terms=hashicorp) episode "Automating Azure Image Pipelines with HCP Packer".
