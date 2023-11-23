# ------------------------------------------------------------------------------
# Keyvault (if using a keyvault to store secrets)
# keyvault_name = 
# keyvault_rg = 

# keyvault_vcsa_password_secret_name = 
# keyvault_nsxt_password_secret_name = 

# ------------------------------------------------------------------------------
# vCenter and NSX-T Manager passwords (if not using a keyvault)
vcsa_password         = "VMware1!"
nsxt_manager_password = "VMware1!"

# ------------------------------------------------------------------------------
# Azure VMware Solution (AVS) configuration
avs_subscription_id = "00000000-0000-0000-0000-000000000000"
avs_rg              = "avs_resource_group"
avs_region          = "eastus2"

avs_sddc_name                   = "avs_sddc_name"
avs_node_sku                    = "av36p"
avs_node_number                 = 3
avs_networkblock                = "10.1.0.0/22"
avs_internet_connection_enabled = false
avs_hcx_token_name              = "a-name-for-the-hcx-token"
avs_er_key_name                 = "a-name-for-the-er-auth-key"