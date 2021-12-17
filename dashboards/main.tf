terraform {
  # just use the local backend, it's easy enough to delete all resources
  # manually when something goes wrong

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1"
    }
  }
}

locals {
  config = jsondecode(file("../config.json"))
}

provider "grafana" {
  url  = local.config.grafana.url
  auth = local.config.grafana.token
}
