terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cartoon-network-rg" {
  name     = "cn-resource-group"
  location = "centralindia"
}

resource "azurerm_virtual_network" "cartoon-network-vnet" {
  name                = "cn-virtual-net"
  location            = azurerm_resource_group.cartoon-network-rg.location
  resource_group_name = azurerm_resource_group.cartoon-network-rg.name
  address_space       = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "cartoon-network-sub1" {
  name                 = "cn-subnet"
  resource_group_name  = azurerm_resource_group.cartoon-network-rg.name
  virtual_network_name = azurerm_virtual_network.cartoon-network-vnet.name
  #This subnet will containe 32 addresses among which Azure reserved 5 address for itself.
  address_prefixes     = ["192.168.1.0/27"]
}

resource "azurerm_network_interface" "cartoon-network-nic" {
  name                = "cn-nic"
  location            = azurerm_resource_group.cartoon-network-rg.location
  resource_group_name = azurerm_resource_group.cartoon-network-rg.name

  ip_configuration {
    name                          = "cn-ipconfig"
    subnet_id                     = azurerm_subnet.cartoon-network-sub1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "cartoon-network-pubip" {
  name                = "cn-public-ip"
  location            = azurerm_resource_group.cartoon-network-rg.location
  resource_group_name = azurerm_resource_group.cartoon-network-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_linux_virtual_machine" "cartoon-network-vm-one" {
  name                  = "cn-vm-one"
  location              = azurerm_resource_group.cartoon-network-rg.location
  resource_group_name   = azurerm_resource_group.cartoon-network-rg.name
  size                  = "Standard_B1s"
  admin_username        = "jenkins_user"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.cartoon-network-nic.id]

  admin_ssh_key {
    username   = "jenkins_user"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  #This option is used to storevms booting data inside Azure storage account. Using Azure Portal too this options is recommended by Azure.
  # boot_diagnostics {
  #   enabled = true
  # }

  tags = {
    environment = "dev"
  }
}