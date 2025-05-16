#
# IDPAY PRODUCTS
#
module "idpay_itn_api_acquirer_product" {
  source = "./.terraform/modules/__v4__/api_management_product"


  product_id   = "idpay_itn_api_acquirer_product"
  display_name = "IDPAY_ITN_ACQUIRER_PRODUCT"
  description  = "IDPAY_ITN_ACQUIRER_PRODUCT"

  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  published             = true
  subscription_required = true
  approval_required     = false

  subscriptions_limit = 0

  policy_xml = file("./apim/api_product/acquirer/policy_acquirer.xml")

  groups = ["developers"]

}

#
# IDPAY API
#

## IDPAY QR-Code payment ACQUIRER API ##
module "idpay_itn_qr_code_payment_acquirer" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-qr-code-payment-acquirer"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN QR-CODE PAYMENT ACQUIRER"
  display_name = "IDPAY ITN QR-CODE PAYMENT ACQUIRER API"
  path         = "idpay-itn/payment/qr-code/merchant"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaypayment/idpay/payment/qr-code/merchant"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_qrcode_payment/acquirer/openapi.qrcode_payment_acquirer.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_acquirer_product.product_id]

}
