locals {
  product    = "${var.prefix}-${var.env_short}"
  project    = "${var.prefix}-${var.env_short}-${var.location_short}-${var.domain}"
  prefix_api = "idpay-itn"
  #
  # Network
  #
  vnet_core_name                = "${local.product}-vnet"
  dns_public_core_name          = "${var.dns_zone_prefix}.${var.external_domain}"
  vnet_core_resource_group_name = "${local.product}-vnet-rg"

  #
  # AKS
  #
  domain_aks_ingress_hostname            = "${var.domain}.${var.location_short}.${var.dns_zone_internal_prefix}.${var.external_domain}"
  domain_aks_ingress_load_balancer_https = "https://${local.domain_aks_ingress_hostname}"

  #
  # KV
  #
  domain_kv_name    = "${local.project}-kv"
  domain_kv_rg_name = "${local.project}-security-rg"

  #
  # APIM
  #
  apim_rg_name   = "cstar-${var.env_short}-api-rg"
  apim_name      = "cstar-${var.env_short}-apim"
  apim_logger_id = "${data.azurerm_api_management.apim_core.id}/loggers/${local.apim_name}-logger"

  #
  # Data
  #
  data_resource_group_name = "${local.project}-data-rg"
  initiative_storage_name  = "cstar${var.env_short}itnidpayinitatvsa"
  initiative_storage_fqdn  = data.azurerm_storage_account.initiative_storage.primary_blob_internet_endpoint

  refund_storage_fqdn = data.azurerm_storage_account.refund_storage.primary_blob_internet_endpoint
  refund_storage_name = "cstar${var.env_short}itnidpayrefundsa"

  #
  # ORIGINS (used for CORS on IDPAY Welfare Portal)
  #
  origins = {
    base = concat(
      [
        "https://portal.${data.azurerm_dns_zone.public.name}",
        "https://management.${data.azurerm_dns_zone.public.name}",
        "https://${local.apim_name}.developer.azure-api.net",
        "https://${local.idpay-portal-hostname}",
      ],
      var.env_short != "p" ? ["https://localhost:3000", "http://localhost:3000", "https://localhost:3001", "http://localhost:3001"] : []
    )
  }

  #
  # Selfcare
  #
  idpay-portal-hostname = "welfare-italy.${data.azurerm_dns_zone.public.name}"
  idpay-oidc-config_url = "https://welfare.${data.azurerm_dns_zone.public.name}/selfcare/openid-configuration.json"
  selfcare-issuer       = "https://${var.env != "prod" ? "${var.env}." : ""}selfcare.pagopa.it"

  # monitor_appinsights_name        = "${local.product}-appinsights"
  # monitor_action_group_slack_name = "SlackPagoPA"
  # monitor_action_group_email_name = "PagoPA"
  # alert_action_group_domain_name  = "${var.prefix}${var.env_short}${var.domain}"
  #
  # # ingress_hostname_prefix               = "${var.instance}.${var.domain}"
  # internal_dns_zone_name                = "${var.dns_zone_internal_prefix}.${var.external_domain}"
  # internal_dns_zone_resource_group_name = "${local.product}-vnet-rg"
  #
  # apim_rg_name = "cstar-${var.env_short}-api-rg"
  # apim_name    = "cstar-${var.env_short}-apim"
  # # apim_logger_id                = "${data.azurerm_api_management.apim_core.id}/loggers/${local.apim_name}-logger"

  #
  # #ORIGINS (used for CORS on IDPAY Welfare Portal)
  # origins = {
  #   base = concat(
  #     [
  #       # "https://portal.${data.azurerm_dns_zone.public.name}",
  #       # "https://management.${data.azurerm_dns_zone.public.name}",
  #       # "https://${local.apim_name}.developer.azure-api.net",
  #       # "https://${local.idpay-portal-hostname}",
  #     ],
  #     var.env_short != "p" ? ["https://localhost:3000", "http://localhost:3000", "https://localhost:3001", "http://localhost:3001"] : []
  #   )
  # }
  #
  # idpay_eventhubs = {
  #   evh01 = {
  #     namespace           = "${local.product}-${var.domain}-evh-ns-01"
  #     resource_group_name = "${local.product}-${var.domain}-msg-rg"
  #   }
  #   evh00 = {
  #     namespace           = "${local.product}-${var.domain}-evh-ns-00"
  #     resource_group_name = "${local.product}-${var.domain}-msg-rg"
  #   }
  # }

  # domain_aks_hostname                      = var.env == "prod" ? "${var.instance}.${var.domain}.internal.cstar.pagopa.it" : "${var.instance}.${var.domain}.internal.${var.env}.cstar.pagopa.it"
  rtd_domain_aks_hostname                  = var.env == "prod" ? "${var.aks_legacy_instance_name}.rtd.internal.cstar.pagopa.it" : "${var.aks_legacy_instance_name}.rtd.internal.${var.env}.cstar.pagopa.it"
  rtd_ingress_load_balancer_hostname_https = "https://${local.rtd_domain_aks_hostname}"
  # initiative_storage_fqdn                  = "${module.idpay_initiative_storage.name}.blob.core.windows.net"
  # reward_storage_fqdn                      = "${module.idpay_refund_storage.name}.blob.core.windows.net"
  #

}
