# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Normalize and cap storage account name to 24 chars
locals {
  sa_base = lower(regexreplace("${var.project_name}${var.environment}", "[^a-z0-9]", ""))
  sa_name = substr("st${local.sa_base}${random_string.suffix.result}", 0, 24)
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Test        = "TestValue"
    Test2       = "TestValue2"
  }
}

resource "azurerm_storage_account" "main" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

resource "azurerm_storage_container" "demo" {
  name                  = "demo-data"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
