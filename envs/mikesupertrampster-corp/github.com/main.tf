variable "github_owner" {
  type = string
}

provider "github" {
  owner = var.github_owner
}

locals {
  repositories = {
    standalone = {
      ".github"         = { topics = ["public"], description = "Public readme." }
      blockchain        = { topics = ["blockchain"], description = "Blockchain exercises." }
      kubernetes-gitops = { topics = ["kubernetes", "gitops"], description = "Gitops repository for kubernetes" }
      gangway-kube-conf = { topics = ["golang", "k8s", "idp"], description = "Commandline to obtain kube-configuration via gangway" }
      nixos             = { topics = ["nixos", "nix", "linux", "os"], description = "NixOS and Home-Manager configurations" }
      packer            = { topics = ["packer", "hashicorp"], description = "Building images via Hashicorp Packer" }
      trader            = { topics = ["finance", "golang", "grafana", "fluxdb", "prometheus"], description = "Trader platform using Prometheus & Grafana" }
      tracing           = { topics = ["opentelemetry", "tracing", "telemetry"], description = "Tracing demo apps" }
      yubikey           = { topics = ["security", "yubikey"], description = "Set up guide for Yubikey (GPG + SSH)" }
      web3              = { topics = ["web3"], description = "Playground for web3 development" }
    }

    terraform = {
      terraform        = { topics = ["terraform", "github", "k8s", "hashicorp"], is_template = true, description = "Terraform for Everything" }
      terraform-aws    = { topics = ["aws", "cloud", "iac", "terraform"], is_template = true, description = "AWS Setup via Terraform" }
      terraform-github = { topics = ["terraform", "github"], description = "Terraform configuration of github" }
      terraform-jaeger = { topics = ["terraform", "jaeger", "serverless"], description = "Terraform deployment of jaeger" }
      terraform-k8s    = { topics = ["terraform", "kubernetes", "k8s"], description = "Terraform deployment of kubernetes" }
      terraform-vault  = { topics = ["terraform", "hashicorp", "vault", "serverless"], is_template = true, description = "Terraform deployment of Vault" }
    }

    terraform-module = {
      github-repository = { topics = ["terraform", "module", "hashicorp", "terraform-registry", "github"], is_template = true, description = "Terraform module for creating creating Github repositories" }
      tfe-management    = { topics = ["terraform", "module", "hashicorp", "terraform-registry", "terraform-cloud"], description = "Terraform modules for setting up TF Cloud" }
    }

    docker-builds = {
      simple-json-server = { topics = ["docker", "golang", "json", "http"], is_template = true, description = "Dynamically serves JSON from files" }
    }

    algo = {
      api             = { topics = ["golang", "json", "http", "finance"], is_template = true, description = "Interacts with the following company information services" }
      batch-collector = { topics = ["golang", "json", "http", "finance"], description = "Collects company information via service API" }
      feeder          = { topics = ["golang", "json", "http", "finance", "prometheus"], description = "Sends company information to Prometheus database" }
    }
  }

  prepend-category = ["terraform-module", "algo"]
}

module "repositories" {
  for_each = merge(flatten([
    for type, repos in local.repositories : {
      for repo, attr in repos : (contains(local.prepend-category, type) ? "${type}-${repo}" : repo) => attr
    }
  ])...)

  source                   = "app.terraform.io/mikesupertrampster-corp/github-repository/module"
  version                  = "1.0.5"
  name                     = each.key
  description              = lookup(each.value, "description", null)
  topics                   = each.value["topics"]
  visibility               = lookup(each.value, "visibility", "public")
  required_status_checks   = { "gitleaks" = true }
  github_branch_protection = true
  is_template              = lookup(each.value, "is_template", false)
  template                 = lookup(each.value, "template", { owner = null, repository = null })
}