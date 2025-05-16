#
# IDPAY PRODUCTS
#
module "idpay_itn_api_io_product" {
  source = "./.terraform/modules/__v4__/api_management_product"


  product_id   = "idpay_itn_api_io_product"
  display_name = "IDPAY_ITN_APP_IO_PRODUCT"
  description  = "IDPAY_ITN_APP_IO_PRODUCT"

  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  published             = true
  subscription_required = false
  approval_required     = false

  subscriptions_limit = 0

  policy_xml = templatefile("./apim/api_product/app_io/policy_io.xml.tpl", {
    env_short             = var.env_short
    ingress_load_balancer = local.rtd_ingress_load_balancer_hostname_https
    appio_timeout_sec     = var.appio_timeout_sec
    rate_limit_io         = var.rate_limit_io_product
  })

  groups = ["developers"]

  depends_on = [
    azurerm_api_management_named_value.pdv_api_key
  ]
}

data "azurerm_key_vault_secret" "pdv_api_key" {
  name         = "pdv-api-key"
  key_vault_id = data.azurerm_key_vault.key_vault_domain.id
}

resource "azurerm_api_management_named_value" "pdv_api_key" {

  name                = "${var.env_short}-${local.prefix_api}-pdv-api-key"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  display_name = "${var.env_short}-${local.prefix_api}-pdv-api-key"
  secret       = true
  value_from_key_vault {
    secret_id = data.azurerm_key_vault_secret.pdv_api_key.versionless_id
  }

}

#
# IDPAY API
#

## IDPAY Onboarding workflow IO API ##
module "idpay_itn_onboarding_workflow_io" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-onboarding-workflow"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Onboarding Workflow IO"
  display_name = "IDPAY ITN Onboarding Workflow IO API"
  path         = "idpay-itn/onboarding"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpayonboardingworkflow/idpay/onboarding"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_onboarding_workflow/openapi.onboarding.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_io_product.product_id]

  api_operation_policies = [
    {
      operation_id = "onboardingCitizen"
      xml_content = templatefile("./apim/api/idpay_onboarding_workflow/put-terms-conditions-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "checkPrerequisites"
      xml_content = templatefile("./apim/api/idpay_onboarding_workflow/put-check-prerequisites-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "onboardingStatus"
      xml_content = templatefile("./apim/api/idpay_onboarding_workflow/get-onboarding-status-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "consentOnboarding"
      xml_content = templatefile("./apim/api/idpay_onboarding_workflow/put-consent-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInitiativeData"

      xml_content = templatefile("./apim/api/idpay_onboarding_workflow/get-initiative-id-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]

}

## IDPAY Wallet IO API ##
module "idpay_itn_wallet_io" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-wallet"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Wallet IO"
  display_name = "IDPAY ITN Wallet IO API"
  path         = "idpay-itn/wallet"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaywallet/idpay/wallet"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_wallet/openapi.wallet.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_io_product.product_id]

  api_operation_policies = [
    {
      operation_id = "getWallet"
      xml_content = templatefile("./apim/api/idpay_wallet/get-wallet-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname,
        webViewUrl                     = var.webViewUrl
      })
    },
    {
      operation_id = "getInitiativeBeneficiaryDetail"
      xml_content = templatefile("./apim/api/idpay_wallet/get-initiative-detail-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getWalletDetail"
      xml_content = templatefile("./apim/api/idpay_wallet/get-wallet-detail-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname,
        webViewUrl                     = var.webViewUrl
      })
    },
    {
      operation_id = "enrollIban"
      xml_content = templatefile("./apim/api/idpay_wallet/put-enroll-iban-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "enrollInstrument"
      xml_content = templatefile("./apim/api/idpay_wallet/put-enroll-instrument-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
        env_short                      = var.env_short

      })
    },
    {
      operation_id = "enrollInstrumentCode"
      xml_content = templatefile("./apim/api/idpay_wallet/put-enroll-instrument-idpaycode-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
        env_short                      = var.env_short

      })
    },
    {
      operation_id = "generateCode"
      xml_content = templatefile("./apim/api/idpay_wallet/post-generate-idpaycode-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
        env_short                      = var.env_short

      })
    },
    {
      operation_id = "getIdpayCodeStatus"
      xml_content = templatefile("./apim/api/idpay_wallet/get-code-status-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
        env_short                      = var.env_short

      })
    },
    {
      operation_id = "deleteInstrument"
      xml_content = templatefile("./apim/api/idpay_wallet/delete-instrument-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getWalletStatus"
      xml_content = templatefile("./apim/api/idpay_wallet/get-wallet-status-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInstrumentList"
      xml_content = templatefile("./apim/api/idpay_wallet/get-instrument-list-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "unsubscribe"

      xml_content = templatefile("./apim/api/idpay_wallet/put-unsuscribe-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInitiativesWithInstrument"

      xml_content = templatefile("./apim/api/idpay_wallet/get-initiative-instrument-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
    /*   ,
    {
      operation_id = "pm-mock-io"

      xml_content = templatefile("./apim/api/idpay_wallet/get-pm-mock-io.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }*/
  ]
}

## IDPAY Timeline IO API ##
module "idpay_itn_timeline_io" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-timeline"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Timeline IO"
  display_name = "IDPAY ITN Timeline IO API"
  path         = "idpay-itn/timeline"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaytimeline/idpay/timeline"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_timeline/openapi.timeline.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_io_product.product_id]

  api_operation_policies = [
    {
      operation_id = "getTimeline"
      xml_content = templatefile("./apim/api/idpay_timeline/get-timeline-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getTimelineDetail"
      xml_content = templatefile("./apim/api/idpay_timeline/get-timeline-detail-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]

}

## IDPAY IBAN Wallet IO API ##
module "idpay_itn_iban_io" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-iban"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN IBAN IO"
  display_name = "IDPAY ITN IBAN IO API"
  path         = "idpay-itn/iban"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpayiban/idpay/iban"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_iban/openapi.iban.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_io_product.product_id]

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

## IDPAY QR-Code payment IO API ##
module "idpay_itn_qr_code_payment_io" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-qr-code-payment-io"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN QR-CODE PAYMENT IO"
  display_name = "IDPAY ITN QR-CODE PAYMENT IO API"
  path         = "idpay-itn/payment/qr-code"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaypayment/idpay/payment/qr-code"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_qrcode_payment/io/openapi.qrcode_payment_io.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_io_product.product_id]

}

## IDPAY Payment IO API ##
module "idpay_itn_payment_io" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-payment-io"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN PAYMENT IO"
  display_name = "IDPAY ITN PAYMENT IO API"
  path         = "idpay-itn/payment"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpaypayment/idpay/payment"

  content_format = "openapi"
  content_value  = templatefile("./apim/api/idpay_payment_io/openapi.payment_io.yml.tpl", {})

  xml_content = file("./apim/api/base_policy.xml")

  product_ids = [module.idpay_itn_api_io_product.product_id]

}
