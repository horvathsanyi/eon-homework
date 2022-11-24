# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "eonhomeworkResourceGroup"
  location = var.location
  tags = {
    "environment" = "dev"
  }
}

resource "azapi_resource" "aca_env" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = "aca-env-terraform"

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.law.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.law.primary_shared_key
        }
      }
      vnetConfiguration = {
        internal               = true
        infrastructureSubnetId = azurerm_subnet.aca_subnet.id
        dockerBridgeCidr       = "10.2.0.1/16"
        platformReservedCidr   = "10.1.0.0/16"
        platformReservedDnsIP  = "10.1.0.2"
      }
    }
  })
  depends_on = [
    azurerm_virtual_network.virtual_network
  ]
  response_export_values  = ["properties.defaultDomain", "properties.staticIp"]
  ignore_missing_property = true

  tags = {
    "environment" = "dev"
  }
}

resource "azapi_resource" "aca" {
  for_each  = { for ca in var.container_apps : ca.name => ca }
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = each.value.name

  body = jsonencode({
    properties : {
      managedEnvironmentId = azapi_resource.aca_env.id
      configuration = {
        ingress = {
          external   = each.value.ingress_enabled
          targetPort = each.value.ingress_enabled ? each.value.containerPort : null
        }
      }
      template = {
        containers = [
          {
            name  = "eonhomewoek-container"
            image = "${each.value.image}:${each.value.tag}"
            resources = {
              cpu    = each.value.cpu_requests
              memory = each.value.mem_requests
            }
          }
        ]
        scale = {
          minReplicas = each.value.min_replicas
          maxReplicas = each.value.max_replicas
          rules = [{
            name = "http-rule",
            http = {
              metadata = {
                concurrentRequests = "100"
              }
          } }]
        }
      }
    }
  })
  depends_on = [
    azapi_resource.aca_env
  ]
  tags = {
    "environment" = "dev"
  }
}