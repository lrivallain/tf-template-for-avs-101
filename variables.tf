# ------------------------------------------------------------------------------
# Keyvault (if using a keyvault to store secrets)
variable "keyvault_name" { type = string }
variable "keyvault_rg" { type = string }

variable "keyvault_vcsa_password_secret_name" { type = string }
variable "keyvault_nsxt_password_secret_name" { type = string }

# ------------------------------------------------------------------------------
# vCenter and NSX-T Manager passwords (if not using a keyvault)
variable "vcsa_password" { type = string }
variable "nsxt_manager_password" { type = string }

# ------------------------------------------------------------------------------
# Azure VMware Solution (AVS) configuration
variable "avs_subscription_id" { type = string }
variable "avs_rg" { type = string }
variable "avs_region" { type = string }

variable "avs_sddc_name" { type = string }
variable "avs_node_sku" {
  type    = string
  default = "av36p"
}
variable "avs_node_number" {
  type    = number
  default = 3
}
variable "avs_networkblock" { type = string }
variable "avs_internet_connection_enabled" {
  type    = bool
  default = false
}
variable "avs_hcx_token_name" { type = string }
variable "avs_er_key_name" { type = string }