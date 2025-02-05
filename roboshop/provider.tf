# Configure the Microsoft Azure Provider
terraform {
  backend "azurerm" {


  }
}

provider "azurerm" {


features {}
  subscription_id = "a92e07d8-3cdd-4fda-bb98-99b2dddb739c"
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"
}
