resource "azurerm_virtual_network" "vnet" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_public_ip" "publicip" {
  name                = "publicip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  name                 = "Websubnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.vnet,
    azurerm_resource_group.rg,
  azurerm_public_ip.publicip]
}

resource "azurerm_network_interface" "nic" {
  name                = "mynic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "publicip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }

  depends_on = [
    azurerm_public_ip.publicip,
    azurerm_subnet.subnet
  ]
}