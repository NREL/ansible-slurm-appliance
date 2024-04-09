terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

variable "cluster_name" {
    type = string
    default = "sussexlab"
}

variable "cluster_image_id" {
    type = string
    default = "7ab9b19c-d1b2-40b6-b5b6-55ef69ae53dc" # openhpc-ofed-RL9-240404-1503-e9fe3235
}

module "cluster" {
    source = "../../sussex-base/terraform/"
    environment_root = var.environment_root

    cluster_name = var.cluster_name
    key_pair = "slurm-app-ci"
    cluster_image_id = var.cluster_image_id

    tenant_net = "sussex-tenant"
    tenant_subnet = "sussex-tenant"
    storage_net = "sussex-storage"
    storage_subnet = "sussex-storage"

    control_node_flavor = "ec1.medium"

    login_nodes = {
        "login-0" = {
            flavor = "en1.xsmall"
            fip = "195.114.30.210"
        }
    }

    compute = {
      standard = {
          flavor = "en1.xsmall"
          nodes = [
            "standard-0",
            "standard-1",
          ]
      }
    }
}