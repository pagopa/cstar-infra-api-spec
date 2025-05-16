#
# IDPAY PRODUCTS
#

module "idpay_api_webview_product" {
  source = "./.terraform/modules/__v4__/api_management_product"


  product_id   = "idpay_itn_api_webview_product"
  display_name = "IDPAY_ITN_API_WEBVIEW PRODUCT"
  description  = "IDPAY_ITN_API_WEBVIEW PRODUCT"

  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  published             = true
  subscription_required = false
  approval_required     = false

  subscriptions_limit = 0

  policy_xml = templatefile("./apim/api_product/webview/policy_webview.xml", {
    rate_limit_io_product = var.rate_limit_io_product
    }
  )

  depends_on = [
    azurerm_api_management_policy_fragment.apim_webview_validate_token_mil
  ]

}

#
# IDPAY API
#

## IDPAY WebView API ##

module "idpay_api_webview" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-self-expense-backend"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Webview"
  display_name = "IDPAY ITN Webview"
  path         = "idpay-itn/self-expense"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpayselfexpensebackend/idpay/self-expense"

  content_format = "openapi"
  content_value  = file("./apim/api/idpay-self-expense/openapi.self-expense.yml.tpl")

  xml_content = file("./apim/api/base_policy.xml")

  product_ids           = [module.idpay_api_webview_product.product_id]
  subscription_required = false

  api_operation_policies = [
    {
      operation_id = "login"

      xml_content = templatefile("./apim/api/idpay-self-expense/login.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getRedirect"

      xml_content = templatefile("./apim/api/idpay-self-expense/get-redirect.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "session"

      xml_content = templatefile("./apim/api/idpay-self-expense/get-session.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getChildForUserId"

      xml_content = templatefile("./apim/api/idpay-self-expense/get-child-for-userid.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "saveExpenseData"

      xml_content = templatefile("./apim/api/idpay-self-expense/save-expense-data.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]

}
