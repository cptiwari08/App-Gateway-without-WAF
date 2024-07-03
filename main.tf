resource "azurerm_resource_group" "example" {
  name     = var.appgw.appgw_rg_name
  location = var.appgw.appgw_location
}

resource "azurerm_virtual_network" "example" {
  name                = var.appgw.appgw_vnet_name
  resource_group_name = var.appgw.appgw_rg_name
  location            = var.appgw.appgw_location
  address_space       = var.appgw.appgw_address_space
}

resource "azurerm_subnet" "example" {
  name                 = var.appgw.appgw_subnet_name
  resource_group_name  = var.appgw.appgw_rg_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.appgw.appgw_address_prefixes
}

resource "azurerm_public_ip" "example" {
  name                = var.appgw.appgw_pip
  resource_group_name = var.appgw.appgw_rg_name
  location            = var.appgw.appgw_location
  allocation_method   = "Static"
  sku = "Standard"
}


resource "azurerm_application_gateway" "network" {
  name                = var.appgw.appgw_name
  resource_group_name = var.appgw.appgw_rg_name
  location            = var.appgw.appgw_location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = var.appgw.appgw_config_ip_name
    subnet_id = azurerm_subnet.example.id
  }

  frontend_port {
    name = var.appgw.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.appgw.frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = var.appgw.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.appgw.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.appgw.listener_name
    frontend_ip_configuration_name = var.appgw.frontend_ip_config_name
    frontend_port_name             = var.appgw.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.appgw.request_routing_rule_name
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = var.appgw.listener_name
    backend_address_pool_name  = var.appgw.backend_address_pool_name
    backend_http_settings_name = var.appgw.http_setting_name
  }
}