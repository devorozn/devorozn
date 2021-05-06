#for local docker connet
#provider "docker" {	
#}


#For provide Kubernetes local
#resource "local_file" "kube_cluster_yaml" {
#  filename = "${path.root}/kube_config_cluster.yml"
#  sensitive_content  = "${rke_cluster.cluster.kube_config_yaml}"
#}

#provider "kubernetes" {
#  host     = rke_cluster.cluster.api_server_url
#  username = rke_cluster.cluster.kube_admin_user
#  client_certificate     = rke_cluster.cluster.client_cert
#  client_key             = rke_cluster.cluster.client_key
#  cluster_ca_certificate = rke_cluster.cluster.ca_crt
#}

#resource "kubernetes_namespace" "getaclubapp" {
#  metadata {
#    name = "terraform-getaclubapp-namespace"
#  }
#}

#For provider Azure cloud
provider "azurerm" {
  features {}
}

#Config resource group
resource "azurerm_resource_group" "getaclubapp" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location
}

#Config resource network
resource "azurerm_virtual_network" "getaclubapp" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.getaclubapp.location
  resource_group_name = azurerm_resource_group.getaclubapp.name
  address_space       = ["10.1.0.0/166"]
}

#Config resource App (getaclubapp)
resource "azuread_application" "getaclubapp" {
  name                       = "${var.prefix}-k8s-app"
  homepage                   = "http://getaclubapp/"
  identifier_uris            = ["http://getaclubapp"]
  reply_urls                 = ["http://getaclubapp"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

#Config resource  Azure princial service
resource "azuread_service_principal" "getaclubapp" {
  application_id               = "${azuread_application.getaclubapp.application_id}"
  app_role_assignment_required = false
}

#Config resource  kubernetes cluster
resource "azurerm_kubernetes_cluster" "getaclubapp" {
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.getaclubapp.location
  resource_group_name = azurerm_resource_group.getaclubapp.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.internal.id
    type           = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "standard"
    outbound_type = "userDefinedRouting"
  }

  service_principal {
    client_id = azuread_service_principal.getaclubapp.application_id
    client_secret = var.service_principal_pw
  }

  addon_profile {
		aci_connector_linux {
		enabled = false
		}
		azure_policy {
		enabled = false
		}

		http_application_routing {
		enabled = false
		}

		kube_dashboard {
		enabled = true
		} 
  }
}