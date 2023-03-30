# Configure the Azure provider
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

resource "azurerm_resource_group" "rg" {
  name     = "ansible-lab-rg"
  location = "centralindia"
}

#Creating network configuration for virtual machine.
resource "azurerm_virtual_network" "vnet" {
  name                = "example-network"
  address_space       = ["192.168.10.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet-1" {
  name                 = "internal-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.10.0/27"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-for-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Creating virtual machine
#Creating virtual machine
resource "azurerm_linux_virtual_machine" "an-w1" {
  name                = "jenkins-server-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "jenkins_user"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "worker"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 70
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  provisioner "file" {
    source = "ansible_installation.sh"
    destination = "~/ansible_installation.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/ansible_installation.sh",
      "~/ansible_installation.sh",
    ]
  }
}
