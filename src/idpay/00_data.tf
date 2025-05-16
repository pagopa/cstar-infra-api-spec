#
# 🔐 KV
#
data "azurerm_key_vault" "key_vault_domain" {
  name                = local.domain_kv_name
  resource_group_name = local.domain_kv_rg_name
}

data "azurerm_key_vault_key" "idpay_mil_key" {
  name         = "idpay-mil-key"
  key_vault_id = data.azurerm_key_vault.key_vault_domain.id
}

data "azurerm_key_vault_certificate" "idpay_jwt_signing_cert" {
  name         = "${local.project}-jwt-signing-cert"
  key_vault_id = data.azurerm_key_vault.key_vault_domain.id
}

data "azurerm_key_vault_certificate" "idpay_merchants_jwt_signing_cert" {
  name         = "${local.project}-merchants-jwt-signing-cert"
  key_vault_id = data.azurerm_key_vault.key_vault_domain.id
}


data "azurerm_key_vault_secret" "selc-external-api-key" {
  name         = "selc-external-api-key"
  key_vault_id = data.azurerm_key_vault.key_vault_domain.id
}

#
# Storage
#
data "azurerm_storage_account" "initiative_storage" {
  name                = local.initiative_storage_name
  resource_group_name = local.data_resource_group_name
}

data "azurerm_storage_account" "refund_storage" {
  name                = local.refund_storage_name
  resource_group_name = local.data_resource_group_name
}
