terraform {
  required_providers {
    cloudflare = {
      source : "cloudflare/cloudflare"
      version = ">= 4.24.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

data "cloudflare_accounts" "cloudflare_account_data" {
  name = "daniel.ware"
}

# resource "cloudflare_d1_database" "example" {
#   account_id = data.cloudflare_accounts.cloudflare_account_data.accounts[0].id
#   name       = "blog"
# }

resource "cloudflare_pages_project" "example" {
  account_id        = data.cloudflare_accounts.cloudflare_account_data.accounts[0].id
  production_branch = "main"
  name              = "d1-drizzle-remix-example"
  build_config {
    build_command   = "npm run build"
    destination_dir = "public"
  }

  deployment_configs {
    preview {
      always_use_latest_compatibility_date = false
      d1_databases                         = {}
      fail_open                            = true
      usage_model                          = "standard"
    }
    production {
      always_use_latest_compatibility_date = false
      d1_databases = {
        "DB" = "ee3023a6-f9d6-42de-a3dd-0ef274f07f23"
        # "DB" = resource.cloudflare_d1_database.example.id
      }
      fail_open   = true
      usage_model = "standard"
    }
  }

  source {
    type = "github"
    config {
      owner               = "Scissortail-Software"
      deployments_enabled = true
      pr_comments_enabled = true
      preview_branch_includes = [
        "*",
      ]
      preview_deployment_setting    = "all"
      production_branch             = "main"
      production_deployment_enabled = true
      repo_name                     = "d1-drizzle-remix-example"
    }
  }
}
