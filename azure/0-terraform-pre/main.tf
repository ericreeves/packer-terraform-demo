# Create a Resource Group if it doesn’t exist
resource "azurerm_resource_group" "demo" {
  name     = "${var.prefix}_rg"
  location = var.location
}

# Creates Shared Image Gallery
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery
resource "azurerm_shared_image_gallery" "demo" {
  name                = "${var.prefix}_sig"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  description         = "Shared images"

  tags = {
    Environment = "${var.env}"
    Department  = "${var.department}"
  }
}

resource "azurerm_shared_image" "ubuntu20-base" {
  name                = "ubuntu20-base"
  gallery_name        = azurerm_shared_image_gallery.demo.name
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = var.prefix
    offer     = "ubuntu_base"
    sku       = "${var.prefix}_ubuntu_base"
  }
}

resource "azurerm_shared_image" "ubuntu20-nginx" {
  name                = "ubuntu20-nginx"
  gallery_name        = azurerm_shared_image_gallery.demo.name
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = var.prefix
    offer     = "ubuntu_nginx"
    sku       = "${var.prefix}_ubuntu_nginx"
  }
}

resource "azurerm_shared_image" "win11-21h2-avd-base" {
  name                = "win11-21h2-avd-base"
  gallery_name        = azurerm_shared_image_gallery.demo.name
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = var.prefix
    offer     = "win11_21h2_avd_base"
    sku       = "${var.prefix}_win11_21h2_avd_base"
  }
}
