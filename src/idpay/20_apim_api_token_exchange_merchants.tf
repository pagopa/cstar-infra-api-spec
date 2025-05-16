
resource "azurerm_api_management_certificate" "idpay_merchants_token_exchange_cert_jwt" {
  name                = "${local.project}-merchants-token-exchange-jwt"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name
  key_vault_secret_id = data.azurerm_key_vault_certificate.idpay_merchants_jwt_signing_cert.versionless_secret_id
}

resource "azurerm_api_management_api" "idpay_merchants_token_exchange" {
  name                = "${var.env_short}-idpay-itn-token-exchange-merchants"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  revision              = "1"
  display_name          = "IDPAY ITN Token Exchange for Merchants Portal"
  path                  = "idpay-itn/merchant/token"
  subscription_required = false
  #service_url           = ""
  protocols = ["https"]

}

resource "azurerm_api_management_api_operation" "idpay_merchants_token_exchange" {
  operation_id        = "idpay-token-exchange-merchants"
  api_name            = azurerm_api_management_api.idpay_merchants_token_exchange.name
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name
  display_name        = "IDPAY Token Exchange for Merchants Portal"
  method              = "POST"
  url_template        = "/"
  description         = "Endpoint for selfcare token exchange towards merchants portal"
}

resource "azurerm_api_management_api_operation_policy" "idpay_merchants_token_exchange_policy" {
  api_name            = azurerm_api_management_api_operation.idpay_merchants_token_exchange.api_name
  api_management_name = azurerm_api_management_api_operation.idpay_merchants_token_exchange.api_management_name
  resource_group_name = azurerm_api_management_api_operation.idpay_merchants_token_exchange.resource_group_name
  operation_id        = azurerm_api_management_api_operation.idpay_merchants_token_exchange.operation_id

  xml_content = templatefile("./apim/api/idpay_token_exchange/jwt_exchange_merchants.xml.tpl", {
    openid-config-url           = local.idpay-oidc-config_url,
    selfcare-issuer             = local.selfcare-issuer,
    jwt_cert_signing_thumbprint = azurerm_api_management_certificate.idpay_merchants_token_exchange_cert_jwt.thumbprint,
    idpay-portal-hostname       = local.idpay-portal-hostname,
    origins                     = local.origins.base
  })

  depends_on = [
    azurerm_api_management_policy_fragment.apim_merchant_id_retriever,
    # azurerm_storage_blob.oidc_configuration
  ]
}

resource "azurerm_api_management_api_operation" "idpay_merchants_token_exchange_test" {
  count               = var.env_short != "p" ? 1 : 0
  operation_id        = "idpay-token-exchange-merchants_test"
  api_name            = azurerm_api_management_api.idpay_merchants_token_exchange.name
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name
  display_name        = "IDPAY Token Exchange for Merchants Portal test"
  method              = "POST"
  url_template        = "/test"
  description         = "Endpoint for selfcare token exchange towards merchants portal test"
}

resource "azurerm_api_management_api_operation_policy" "idpay_merchants_token_exchange_policy_test" {
  count               = var.env_short != "p" ? 1 : 0
  api_name            = azurerm_api_management_api_operation.idpay_merchants_token_exchange_test[0].api_name
  api_management_name = azurerm_api_management_api_operation.idpay_merchants_token_exchange_test[0].api_management_name
  resource_group_name = azurerm_api_management_api_operation.idpay_merchants_token_exchange_test[0].resource_group_name
  operation_id        = azurerm_api_management_api_operation.idpay_merchants_token_exchange_test[0].operation_id

  xml_content = templatefile("./apim/api/idpay_token_exchange/jwt_merchants_token_test.xml.tpl", {
    ingress_load_balancer_hostname = local.domain_aks_ingress_hostname,
    jwt_cert_signing_thumbprint    = azurerm_api_management_certificate.idpay_merchants_token_exchange_cert_jwt.thumbprint,
    origins                        = local.origins.base
  })

}
