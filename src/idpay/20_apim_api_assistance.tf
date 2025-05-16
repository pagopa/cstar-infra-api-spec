#
# IDPAY PRODUCTS
#

module "idpay_itn_api_assistance_product" {
  source = "./.terraform/modules/__v4__/api_management_product"


  product_id   = "idpay_itn_api_assistance_product"
  display_name = "IDPAY_ITN_API_ASSISTANCE PRODUCT"
  description  = "IDPAY_ITN_API_ASSISTANCE PRODUCT"

  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  published             = true
  subscription_required = true
  approval_required     = true

  subscriptions_limit = 50

  policy_xml = templatefile("./apim/api_product/assistance/policy_assistance.xml", {
    rate_limit_assistance = var.rate_limit_assistance_product
    }
  )

}

#
# IDPAY API
#

## IDPAY Assistance API ##

module "idpay_itn_api_assistance" {
  source = "./.terraform/modules/__v4__/api_management_api"

  name                = "${var.env_short}-idpay-itn-assistance"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY ITN Assistance"
  display_name = "IDPAY ITN Assistance"
  path         = "idpay-itn/assistance"
  protocols    = ["https"]

  service_url = "${local.domain_aks_ingress_load_balancer_https}/idpayportalwelfarebackeninitiative/idpay/initiative"

  content_format = "openapi"
  content_value  = file("./apim/api/idpay_assistance/openapi.assistance.yml")

  xml_content = file("./apim/api/base_policy.xml")

  product_ids           = [module.idpay_itn_api_assistance_product.product_id]
  subscription_required = true

  api_operation_policies = [
    {
      operation_id = "getListOfOrganization"

      xml_content = templatefile("./apim/api/idpay_assistance/get-organization-list.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInitativeSummary"

      xml_content = templatefile("./apim/api/idpay_assistance/get-initiative-summary.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInitiativeDetail"

      xml_content = templatefile("./apim/api/idpay_assistance/get-initiative-detail.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "initiativeStatistics"

      xml_content = templatefile("./apim/api/idpay_assistance/get-initiative-statistics.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getRewardNotificationExportsPaged"

      xml_content = templatefile("./apim/api/idpay_assistance/get-initiative-reward-notifications-exp.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getRewardNotificationImportsPaged"

      xml_content = templatefile("./apim/api/idpay_assistance/get-initiative-reward-notifications-imp.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getOnboardingStatus"

      xml_content = templatefile("./apim/api/idpay_assistance/get-onboarding-status.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInitiativeOnboardingRankingStatusPaged"

      xml_content = templatefile("./apim/api/idpay_assistance/get-ranking.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getRankingFileDownload"

      xml_content = templatefile("./apim/api/idpay_assistance/get-ranking-download.xml.tpl", {
        initiative-storage-account-fqdn-private = data.azurerm_storage_account.initiative_storage.primary_blob_internet_host
      })
    },
    {
      operation_id = "getRewardFileDownload"

      xml_content = templatefile("./apim/api/idpay_assistance/get-reward-download.xml.tpl", {
        refund-storage-account-name = data.azurerm_storage_account.refund_storage.name
      })
    },
    {
      operation_id = "getDispFileErrors"

      xml_content = templatefile("./apim/api/idpay_assistance/get-disp-errors.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    //BENEFICIARY DETAIL
    {
      operation_id = "getIban"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-iban.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getTimeline"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-timeline.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getTimelineDetail"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-timeline-detail.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getWalletDetail"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-wallet.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getBeneficiaryOnboardingStatus"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-onboarding-status.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getFamilyComposition"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-onboarding-family-status.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getInstrumentList"

      xml_content = templatefile("./apim/api/idpay_assistance/get-beneficiary-instruments.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    //REFUND DETAIL
    {
      operation_id = "getExportSummary"

      xml_content = templatefile("./apim/api/idpay_assistance/get-refund-export-summary.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getExportRefundsListPaged"

      xml_content = templatefile("./apim/api/idpay_assistance/get-refund-list.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getRefundDetail"

      xml_content = templatefile("./apim/api/idpay_assistance/get-refund-detail.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
        pdv_timeout_sec                = var.pdv_timeout_sec
        pdv_tokenizer_url              = var.pdv_tokenizer_url
        pdv_retry_count                = var.pdv_retry_count
        pdv_retry_interval             = var.pdv_retry_interval
        pdv_retry_max_interval         = var.pdv_retry_max_interval
        pdv_retry_delta                = var.pdv_retry_delta
      })
    },
    {
      operation_id = "getMerchantList"

      xml_content = templatefile("./apim/api/idpay_assistance/get-merchant-list-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getMerchantDetail"

      xml_content = templatefile("./apim/api/idpay_assistance/get-merchant-detail-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getMerchantInitiativeStatistics"

      xml_content = templatefile("./apim/api/idpay_assistance/get-merchant-statistics-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getMerchantTransactions"

      xml_content = templatefile("./apim/api/idpay_assistance/get-merchant-transactions-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    },
    {
      operation_id = "getMerchantTransactionsProcessed"

      xml_content = templatefile("./apim/api/idpay_assistance/get-merchant-transactions-processed-policy.xml.tpl", {
        ingress_load_balancer_hostname = local.domain_aks_ingress_hostname
      })
    }
  ]

}
