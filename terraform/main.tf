# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
}

# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create a virtual network 
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a network public IP
resource "azurerm_public_ip" "publicip" {
  name                = "${var.prefix}-publicip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"

  tags = {
    environment = "Development"
  }
}

# Create a load balancer
resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

# Create a address pool
resource "azurerm_lb_backend_address_pool" "lb_adr_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}

# Create a address pool address...
#....

resource "azurerm_network_interface_backend_address_pool_association" "nic_adr_pool_acc" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_adr_pool.id
}

# Create a network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

# Create a network security rule to allow all access from other VMs in the VNet
resource "azurerm_network_security_rule" "nsr-1" {
  name                        = "AllowVNetInboundTraffic"
  priority                    = 65000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Any"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = ["10.0.0.0/16"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Create a network security rule to deny all other inbound traffic
resource "azurerm_network_security_rule" "nsr-2" {
  name                        = "DenyAllOtherInbound"
  priority                    = 65500
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Any"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = ["0.0.0.0/0"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Create a virtual machine availability set
resource "azurerm_availability_set" "aset" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  tags = {
    environment = "Development"
  }
}

# Create a virtual machine 
resource "azurerm_linux_virtual_machine" "vm" {
    name = "${var.prefix}-vm"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = azurerm_resource_group.resource_group.location
    size = "Standard_D2s_v3"
    admin_username      = "adminuser"
    network_interface_ids = [azurerm_network_interface.nic.id]

    admin_ssh_key {
      username   = "adminuser"
      public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      managed_image_name = "ubuntuImage"
    }
}