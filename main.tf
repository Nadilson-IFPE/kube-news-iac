terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocen_droplet" "k8s_iniciativa_devops_nadilson_droplet" {
  image    = "ubutunt-22-04-x64"
  name     = "k8s_iniciativa_devops_nadilson_droplet"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = "data.digitalocean_ssh_keyk8s_iniciativa_devops_nadilson_ssh_key.id"
}

data "digitalocean_ssh_key" "k8s_iniciativa_devops_nadilson_ssh_key" {
  name = var.ssh_key_name
}

resource "digitalocean_kubernetes_cluster" "k8s_iniciativa_devops_nadilson" {
  name   = var.k8s_name
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_node_pool" "node_premium_nadilson" {
  cluster_id = digitalocean_kubernetes_cluster.k8s_iniciativa_devops_nadilson.id

  name       = "premium_nadilson"
  size       = "s-4vcpu-8gb"
  node_count = 1
}

variable "do_token" {}
variable "k8s_name" {}
variable "region" {}
variable "ssh_key_name" {}


output "kube_endpoint" {
  value = digitalocean_kubernetes_cluster.k8s_iniciativa_devops_nadilson.endpoint
}

resource "local_file" "kube_config" {
  content  = digitalocean_kubernetes_cluster.k8s_iniciativa_devops_nadilson.kube_config.0.raw_config
  filename = "kube_config.yaml"
}

