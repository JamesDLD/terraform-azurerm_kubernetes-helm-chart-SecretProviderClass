# -
# -  Variable
# -
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "aks_cluster" {
  description = "AKS Cluster properties"
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "helm_release" {
  description = "A Release is an instance of a chart running in a Kubernetes cluster. https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release"
  default = {
    demo = {
      chart_path = "/charts/SecretProviderClass"
      values_paths = [
        "/charts/SecretProviderClass/values.yaml",
        "/charts/SecretProviderClass/values-demo.yaml"
      ]
      set = [
        {
          name = "tenantId"
        },
        {
          name  = "userAssignedIdentityID"
          value = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx" #Application ID of the managed identity "azurekeyvaultsecretsprovider-<AKS Cluster Name>"
        },
        {
          name  = "keyvaultName"
          value = "xxxxxxxxxxxx"
        }
      ]
    }
  }
}

# -
# -  Backend
# -
terraform {
  backend "local" {}
  #Using a local backend just for the demo, the recommendation is to use a remote backend, see : https://jamesdld.github.io/terraform/Best-Practice/BestPractice-1/
}

# -
# - Providers
# -
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
  }
}

data "azurerm_client_config" "current" {}

# -
# - Azure Kubernetes Service cluster
# -
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster.name
  resource_group_name = var.aks_cluster.resource_group_name
}

# -
# - Helm charts
# -
resource "helm_release" "helm_release" {
  for_each      = var.helm_release
  name          = lookup(each.value, "name", each.key)
  chart         = "${path.module}${each.value.chart_path}"
  values        = lookup(each.value, "values_paths", null) == null ? null : [for x in each.value.values_paths : file(format("%s%s", path.module, x))]
  recreate_pods = lookup(each.value, "recreate_pods", null)

  dynamic "set" {
    for_each = lookup(each.value, "set", [])
    content {
      name  = set.value.name
      value = lookup(set.value, "name", null) == "tenantId" ? data.azurerm_client_config.current.tenant_id : set.value.value
      type  = lookup(set.value, "type", null)
    }
  }
}
