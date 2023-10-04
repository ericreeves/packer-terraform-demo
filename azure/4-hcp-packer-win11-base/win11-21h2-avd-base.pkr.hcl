packer {
  required_version = ">= 1.7.7"
  required_plugins {
    azure = {
      version = ">= 2.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.prefix}-ubuntu20-${local.timestamp}"
}

source "azure-arm" "base" {
  os_type                   = "Windows"
  build_resource_group_name = var.az_resource_group
  vm_size                   = "Standard_D4ds_v4"

  # WinRM
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_username = "packer"

  # Source image
  image_publisher = "MicrosoftWindowsDesktop"
  image_offer     = "office-365"
  image_sku       = "win11-21h2-avd-m365"
  image_version   = "22000.1936.230509"

  # Destination image
  managed_image_name                = local.image_name
  managed_image_resource_group_name = var.az_resource_group
  shared_image_gallery_destination {
    subscription         = var.az_subscription_id
    resource_group       = var.az_resource_group
    gallery_name         = var.az_image_gallery
    image_name           = "win11-21h2-avd-base"
    image_version        = formatdate("YYYY.MMDD.hhmm", timestamp())
    replication_regions  = [var.az_region]
    storage_account_type = "Standard_LRS"
  }

  azure_tags = {
    owner      = var.owner
    department = var.department
    build-time = local.timestamp
    ExcludeMdeAutoProvisioning = "True" 

  }
  use_azure_cli_auth = true
}

build {
  # HCP Packer metadata
  hcp_packer_registry {
    bucket_name = "win11-21h2-avd-base"
    description = "Windows 11 21H2 AVD Base Image"
    bucket_labels = {
      "owner"           = var.owner
      "department"      = var.department
      "os"              = "win11",
      "windows-version" = "21h2",
    }
    build_labels = {
      "build-time" = local.timestamp
    }
  }

  sources = [
    "source.azure-arm.base"
  ]

  # Install Chocolatey: https://chocolatey.org/install#individual
  provisioner "powershell" {
    inline = ["Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"]
  }

  # Install Chocolatey packages
  provisioner "file" {
    source      = "./packages.config"
    destination = "D:/packages.config"
  }

  provisioner "powershell" {
    inline = ["choco install --confirm D:/packages.config"]
    # See https://docs.chocolatey.org/en-us/choco/commands/install#exit-codes
    valid_exit_codes = [0, 3010]
  }

  provisioner "windows-restart" {}

  # Azure PowerShell Modules
  provisioner "powershell" {
    script = "./install-azure-powershell.ps1"
  }

  # Generalize image using Sysprep
  # See https://www.packer.io/docs/builders/azure/arm#windows
  # See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer#define-packer-template
  provisioner "powershell" {
    inline = [
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit"
    ]
  }
}