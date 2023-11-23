# Uncomment if you want to use Azure Key Vault to store sensitive data

# data "azurerm_key_vault" "avs_config" {
#   provider            = azurerm.identity-sub
#   name                = var.keyvault_name
#   resource_group_name = var.keyvault_rg
# }

# data "azurerm_key_vault_secret" "vcsa_password" {
#   provider     = azurerm.identity-sub
#   name         = var.keyvault_vcsa_password_secret_name
#   key_vault_id = data.azurerm_key_vault.avs_config.id
# }

# data "azurerm_key_vault_secret" "nsxt_manager_password" {
#   provider     = azurerm.identity-sub
#   name         = var.keyvault_nsxt_password_secret_name
#   key_vault_id = data.azurerm_key_vault.avs_config.id
# }


# Resource group for AVS
resource "azurerm_resource_group" "avs_rg" {
  provider = azurerm.avs-sub
  name     = var.avs_rg
  location = var.avs_region

  tags = {
    # Example:
    # Environment = var.tag_environment
  }
}

# AVS SDDC
resource "azurerm_vmware_private_cloud" "avs" {
  provider            = azurerm.avs-sub
  name                = var.avs_sddc_name
  resource_group_name = azurerm_resource_group.avs_rg.name
  location            = var.avs_region
  sku_name            = var.avs_node_sku

  management_cluster {
    size = var.avs_node_number
  }

  network_subnet_cidr         = var.avs_networkblock
  internet_connection_enabled = var.avs_internet_connection_enabled

  # Uncomment if you want to use Azure Key Vault to store sensitive data
  # nsxt_password               = data.azurerm_key_vault_secret.nsxt_manager_password.value
  # vcenter_password            = data.azurerm_key_vault_secret.vcsa_password.value

  # Comment if you want to use Azure Key Vault to store sensitive data
  nsxt_password    = var.vcsa_password
  vcenter_password = var.nsxt_manager_password

  lifecycle {
    ignore_changes = [
      nsxt_password,
      vcenter_password
    ]
  }
}

# Provisionning HCX addon on AVS
resource "null_resource" "avs_hcx_addon" {
  provisioner "local-exec" {
    command = join("", [
      "az vmware addon hcx create --subscription '${var.avs_subscription_id}'",
      "  --resource-group ${var.avs_rg}",
      "  --private-cloud ${var.avs_sddc_name}",
      "  --offer 'VMware MaaS Cloud Provider (Enterprise)'"
    ])
  }

  depends_on = [
    azurerm_vmware_private_cloud.avs,
  ]
}

# Create initial HCX token
resource "null_resource" "avs_hcx_token" {
  provisioner "local-exec" {
    command = join("", [
      "az rest --method put --url",
      " 'https://management.azure.com/subscriptions/${var.avs_subscription_id}/resourceGroups/${var.avs_rg}/providers/Microsoft.AVS/privateClouds/${var.avs_sddc_name}/hcxEnterpriseSites/${var.avs_hcx_token_name}?api-version=2021-12-01'",
      " --headers commandName='VMCP.' --body='{}' | jq '.properties.activationKey' -r > .hcx-token.txt"
    ])
  }

  depends_on = [
    null_resource.avs_hcx_addon
  ]
}

# Store HCX token in local file for being usable as output
data "local_file" "avs_hcx_token" {
  filename = ".hcx-token.txt"
  depends_on = [
    null_resource.avs_hcx_token
  ]
}

# Create Express Route authorization key
resource "azurerm_vmware_express_route_authorization" "expressroute_authkey" {
  provider         = azurerm.avs-sub
  name             = var.avs_er_key_name
  private_cloud_id = azurerm_vmware_private_cloud.avs.id
  depends_on = [
    azurerm_vmware_private_cloud.avs
  ]
}


# Create some outputs
# vCenter
output "avs_vcsa_endpoint" {
  value = azurerm_vmware_private_cloud.avs.vcsa_endpoint
}

output "avs_vcsa_manager_username" {
  value = "cloudadmin@vsphere.local"
}

# NSX-T
output "avs_nsxt_manager_endpoint" {
  value = azurerm_vmware_private_cloud.avs.nsxt_manager_endpoint
}

output "avs_nsxt_manager_username" {
  value = "admin"
}

# HCX token
output "avs_hcx_token" {
  value = data.local_file.avs_hcx_token.content
}

# Express Route data
output "avs_expressroute_authkey" {
  value = azurerm_vmware_express_route_authorization.expressroute_authkey.express_route_authorization_key
}
output "avs_expressroute_id" {
  value = azurerm_vmware_private_cloud.gbb_avs.circuit[0].express_route_id
}