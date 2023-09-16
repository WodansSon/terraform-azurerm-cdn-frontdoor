resource "azurerm_dns_zone" "dns_zone" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"

  response_timeout_seconds = var.response_timeout_seconds

  tags = var.profile_tags
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = var.origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  session_affinity_enabled = true

  health_probe   = var.health_probe
  load_balancing = var.load_balancing
  
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = var.restore_traffic_time_to_healed_or_new_endpoint_in_minutes
}

resource "azurerm_cdn_frontdoor_origin" "test" {
  name                          = "XXXXX-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id

  enabled                        = true
  certificate_name_check_enabled = false
  host_name                      = join(".", ["contoso", azurerm_dns_zone.dns_zone.name])
  # origin_host_header             = join(".", ["contoso", azurerm_dns_zone.dns_zone.name])
  priority                       = 1
  weight                         = 1
}

resource "azurerm_cdn_frontdoor_endpoint" "contoso" {
  name                     = "XXXXX-endpoint-contosos"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "firewall_policy" {
  name                              = "XXXXXWAF"
  resource_group_name               = var.resource_group_name
  sku_name                          = azurerm_cdn_frontdoor_profile.profile.sku_name
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://www.contoso.com"
  custom_block_response_status_code = 403
  custom_block_response_body        = "PGh0bWw+PGhlYWRlcj48dGl0bGU+NDAzIC0gRm9yYmlkZGVuOiBBY2Nlc3MgaXMgZGVuaWVkPC90aXRsZT48L2hlYWRlcj48Ym9keT48aDE+Rm9yYmlkZGVuPC9oMT48cD5Zb3UgZG9uJ3QgaGF2ZSBwZXJtaXNzaW9uIHRvIGFjY2VzcyB0aGlzIHJlc291cmNlLjwvcD48L2JvZHk+PC9odG1sPg=="

  custom_rule {
    name                           = "RateLimitExcessiveRequests"
    enabled                        = true
    type                           = "RateLimitRule"
    priority                       = 1000
    rate_limit_threshold           = 3600
    rate_limit_duration_in_minutes = 5
    action                         = "Block"

    match_condition {
      match_variable = "SocketAddr"
      operator       = "IPMatch"
      match_values   = ["0.0.0.0/0"]
    }
  }

  custom_rule {
    name                           = "ShortUserAgents"
    enabled                        = true
    type                           = "MatchRule"
    priority                       = 500
    rate_limit_threshold           = 1
    rate_limit_duration_in_minutes = 5
    action                         = "Block"

    match_condition {
      match_variable = "RequestHeader"
      selector       = "User-Agent"
      operator       = "LessThanOrEqual"
      match_values   = ["15"]
    }
  }

  managed_rule {
    type    = "DefaultRuleSet"
    version = "preview-0.1"
    action  = "Block"

    override {
      rule_group_name = "PHP"

      rule {
        rule_id = "933111"
        enabled = false
        action  = "Block"
      }
    }
  }

  managed_rule {
    type    = "BotProtection"
    version = "preview-0.1"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "XXXXXruleset"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
}

# resource "azurerm_cdn_frontdoor_rule" "test" {
#   depends_on = [azurerm_cdn_frontdoor_origin_group.origin_group,
#                 azurerm_cdn_frontdoor_origin.origin]

#   name                      = "repro18249"
#   cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.test.id
#   order                     = 1
#   behavior_on_match         = "Continue"

#   actions {
#     route_configuration_override_action {
#       cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
#       forwarding_protocol           = "HttpsOnly"
#       query_string_caching_behavior = "IncludeSpecifiedQueryStrings"
#       query_string_parameters       = ["foo", "clientIp={client_ip}"]
#       compression_enabled           = true
#       cache_behavior                = "OverrideIfOriginMissing"
#       cache_duration                = "365.23:59:59"
#     }

#     # Repro for #18249
#     url_redirect_action {
#       redirect_type        = "PermanentRedirect"
#       redirect_protocol    = "Https"
#       destination_hostname = ""
#     }
#   }

#   conditions {
#     request_scheme_condition {
#       match_values = ["HTTP"]
#       negate_condition = false
#       operator = "Equal"
#     }

#     host_name_condition {
#       operator         = "Equal"
#       negate_condition = false
#       match_values     = ["www.wodans-son.com", "images.wodans-son.com", "video.wodans-son.com"]
#       transforms       = ["Lowercase", "Trim"]
#     }

#     is_device_condition {
#       operator         = "Equal"
#       negate_condition = false
#       match_values     = ["Mobile"]
#     }

#     post_args_condition {
#       post_args_name = "customerName"
#       operator       = "BeginsWith"
#       match_values   = ["J", "K"]
#       transforms     = ["Uppercase"]
#     }

#     url_filename_condition {
#       operator         = "Equal"
#       negate_condition = false
#       match_values     = ["media.mp4"]
#       transforms       = ["Lowercase", "RemoveNulls", "Trim"]
#     }
#   }
# }

resource "azurerm_cdn_frontdoor_rule" "test" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.origin_group,
                azurerm_cdn_frontdoor_origin.origin]

  name                      = "repro20652"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.test.id
  order                     = 1

  actions {
    url_rewrite_action {
      destination             = "/static_content"
      preserve_unmatched_path = true
      source_pattern          = "/"
    }
  }

  conditions {
    url_path_condition {
      match_values = ["static/"]
      operator     = "BeginsWith"
    }
    url_path_condition {
      match_values     = ["static/homepage/"]
      negate_condition = true
      operator         = "BeginsWith"
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "test" {
  name                     = "MySecurityPolicy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.firewall_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.contoso.id
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "contoso" {
  name                          = "XXXXX-route-contoso"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.contoso.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.origin.id]
  enabled                       = true

  https_redirect_enabled     = true
  forwarding_protocol        = "HttpsOnly"
  patterns_to_match          = ["/contoso"]
  supported_protocols        = ["Http", "Https"]
  cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.test.id]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.contoso.id]
  link_to_default_domain          = true

  cache {
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
    query_strings                 = ["account", "settings", "foo", "bar"]
    query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "contoso" {
  name                     = "contoso-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  dns_zone_id              = azurerm_dns_zone.dns_zone.id
  host_name                = join(".", ["contoso", azurerm_dns_zone.dns_zone.name])

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "contoso" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.contoso.id
  cdn_frontdoor_route_ids = [azurerm_cdn_frontdoor_route.contoso.id]
}

resource "azurerm_dns_txt_record" "contoso" {
  name                = join(".", ["_dnsauth", "contoso"])
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.contoso.validation_token
  }
}

resource "azurerm_dns_cname_record" "contoso" {
  depends_on = [azurerm_cdn_frontdoor_route.contoso, azurerm_cdn_frontdoor_security_policy.test]

  name                = "contoso"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.contoso.host_name
}
