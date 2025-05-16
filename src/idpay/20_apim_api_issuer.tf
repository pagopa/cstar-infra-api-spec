#
# IDPAY PRODUCTS
#
module "idpay_itn_api_issuer_product" {
  source = "./.terraform/modules/__v4__/api_management_product"


  product_id   = "idpay_itn_api_issuer_product"
  display_name = "IDPAY_ITN_APP_ISSUER_PRODUCT"
  description  = "IDPAY_ITN_APP_ISSUER_PRODUCT"

  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  published             = true
  subscription_required = true
  approval_required     = true

  subscriptions_limit = 50

  policy_xml = templatefile("./apim/api_product/app_issuer/policy_issuer.xml.tpl", {
    env_short         = var.env_short
    rtd_ingress_ip    = var.reverse_proxy_rtd
    rate_limit_issuer = var.rate_limit_issuer_product
  })

  groups = ["developers"]

  depends_on = [
    azurerm_api_management_named_value.pdv_api_key
  ]
}

#
# IDPAY API ISSUER
#

## IDPAY Onboarding workflow ISSUER API ##
module "idpay_itn_onboarding_workflow_issuer" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-issuer-onboarding-workflow"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Onboarding Workflow Issuer"
  display_name = "IDPAY ITN Onboarding Workflow Issuer API"
  path         = "idpay-itn/hb/onboarding"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpayonboardingworkflow/idpay/onboarding"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_issuer_onboarding_workflow/openapi.issuer.onboarding.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_issuer_product.product_id]

  api_operation_policies = [
    {
      operation_id = "onboardingInitiativeList"
      xml_content = templatefile("./apim/api/idpay_issuer_onboarding_workflow/get-initiativelist-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "onboardingCitizen"
      xml_content = templatefile("./apim/api/idpay_issuer_onboarding_workflow/put-terms-conditions-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "checkPrerequisites"
      xml_content = templatefile("./apim/api/idpay_issuer_onboarding_workflow/put-check-prerequisites-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "onboardingStatus"
      xml_content = templatefile("./apim/api/idpay_issuer_onboarding_workflow/get-onboarding-status-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]

}

## IDPAY Wallet IO API ##
module "idpay_itn_wallet_issuer" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-issuer-wallet"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Wallet Issuer"
  display_name = "IDPAY ITN Wallet Issuer API"
  path         = "idpay-itn/hb/wallet"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaywallet/idpay/wallet"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_issuer_wallet/openapi.issuer.wallet.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_issuer_product.product_id]

  api_operation_policies = [
    {
      operation_id = "getWalletDetail"
      xml_content = templatefile("./apim/api/idpay_issuer_wallet/get-wallet-detail-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "enrollIban"
      xml_content = templatefile("./apim/api/idpay_issuer_wallet/put-enroll-iban-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "enrollInstrument"
      xml_content = templatefile("./apim/api/idpay_issuer_wallet/put-enroll-instrument-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
        env_short                      = var.env_short
        pm-timeout-sec                 = var.pm_timeout_sec
        pm-backend-url                 = var.pm_backend_url
      })
    },
    {
      operation_id = "getWalletStatus"
      xml_content = templatefile("./apim/api/idpay_issuer_wallet/get-wallet-status-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInstrumentList"
      xml_content = templatefile("./apim/api/idpay_issuer_wallet/get-instrument-list-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]
}

## IDPAY Timeline IO API ##
module "idpay_itn_timeline_issuer" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-issuer-timeline"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Timeline Issuer"
  display_name = "IDPAY ITN Timeline Issuer API"
  path         = "idpay-itn/hb/timeline"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaytimeline/idpay/timeline"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_issuer_timeline/openapi.issuer.timeline.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_issuer_product.product_id]

  api_operation_policies = [
    {
      operation_id = "getTimelineRefund"
      xml_content = templatefile("./apim/api/idpay_issuer_timeline/get-timeline-refund-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]
}

/*
## IDPAY IBAN Wallet IO API ##
module "idpay_itn_iban_io" {
  source = "git::https://github.com/pagopa/azurerm.git//api_management_api?ref=v2.18.2"

  name                = "${var.env_short}-idpay-iban"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY IBAN IO"
  display_name = "IDPAY IBAN IO API"
  path         = "idpay-itn/iban"
  protocols    = ["https"]

  service_url = "${local.ingress_load_balancer_https}/idpayiban/idpay/iban"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_iban/openapi.iban.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_api_io_product.product_id]

  api_operation_policies = [
    {
      operation_id = "getIban"
      xml_content = templatefile("./apim/api/idpay_iban/get-iban-detail-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getIbanList"
      xml_content = templatefile("./apim/api/idpay_iban/get-iban-list-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]

}
*/
