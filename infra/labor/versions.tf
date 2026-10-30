terraform {
  required_version = ">= 1.10.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.48.0, < 2.0.0"
    }
  }

  # Zustand (State) liegt in Hetzner Object Storage.
  # Bucket, Endpoint und Zugangsdaten kommen aus der Pipeline (-backend-config).
  backend "s3" {
    key = "labor/terraform.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true
  }
}

provider "hcloud" {
  # Token kommt aus der Umgebungsvariable HCLOUD_TOKEN (GitHub Secret).
}
