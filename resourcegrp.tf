resource "azurerm_resource_group" "myrg" {
  name     = "myrg"
  location = "eastus"
}

resource "azurerm_virtual_network" "myvnet" { # Resource BLOCK
  name                = "myvnet-1" # Argument
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.myrg.location # Argument with value as expression
  resource_group_name = azurerm_resource_group.myrg.name # Argument with value as expression
  tags =  {
      mynet = "mangeshnet"
      env = "production"
  }
}

resource "azurerm_subnet" "mysubnet" {
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes = ["192.168.1.0/25"]
  resource_group_name = azurerm_resource_group.myrg.name
  name = "mysubnet"
}

resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}


resource "azurerm_linux_virtual_machine" "mymachine" {
  location = azurerm_resource_group.myrg.location
  name = "mymachine"
  size = "Standard_F2"
  resource_group_name = azurerm_resource_group.myrg.name
  os_disk {
     caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_username = "mymangesh"
  admin_password = "Mypassword123"
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  } 
  disable_password_authentication = false
}