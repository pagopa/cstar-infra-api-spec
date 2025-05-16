locals {
  idpay_itn_apim_api_diagnostics = [
    module.idpay_itn_onboarding_workflow_issuer.name,
    module.idpay_itn_wallet_issuer.name,
    module.idpay_itn_timeline_issuer.name,
    module.idpay_itn_onboarding_workflow_io.name,
    module.idpay_itn_wallet_io.name,
    module.idpay_itn_timeline_io.name,
    module.idpay_itn_iban_io.name,
    module.idpay_itn_initiative_portal.name,
    module.idpay_itn_group_portal.name,
    module.idpay_itn_permission_portal.name,
    module.idpay_itn_merchant_portal.name,
    module.idpay_itn_notification_email_api.name,
    module.idpay_itn_merchants_permission_portal.name,
    #module.idpay_itn_merchants_notification_email_api.name,
    module.idpay_itn_merchants_portal.name,
    module.idpay_itn_qr_code_payment_acquirer.name,
    module.idpay_itn_qr_code_payment_io.name,
    module.idpay_itn_payment_io.name,
    module.idpay_itn_mil_payment.name,
    module.idpay_itn_mil_merchant.name,
    module.idpay_itn_mil_onboarding.name,
    module.idpay_itn_min_int.name
  ]
}

resource "azurerm_api_management_api_diagnostic" "idpay_itn_apim_api_diagnostics" {
  for_each = toset(local.idpay_itn_apim_api_diagnostics)

  identifier               = "applicationinsights"
  resource_group_name      = data.azurerm_resource_group.apim_rg.name
  api_management_name      = data.azurerm_api_management.apim_core.name
  api_name                 = each.key
  api_management_logger_id = local.apim_logger_id

  always_log_errors = true
  verbosity         = "information"

  frontend_request {
    headers_to_log = [
      "X-Forwarded-For"
    ]
  }
}

