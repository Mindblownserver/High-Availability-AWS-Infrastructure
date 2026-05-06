# The terraform block configures terraform itself
# Providers, terraform version
# We configure terraform in a separated file terraform.tf
terraform {
  required_providers {
    # This var name is used in main.tf line 1
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.92"
    }
  }
  required_version = ">=1.2"
}
# Terraform providers (for example aws) are stored in Terraform Registry.
/*
For each provider, they have source and version
- source follows syntax: hostname/namespace/provider. 
For aws' case, it's registry.terraform.io/hashicorp/aws or hashicorp/aws for short

- version sets version constraint on the provider. It's recommended to use it, because terraform defaults to installing most recent version
version = "~>5.92" <=> any version whose major = 5 and minor =92 (Allows only the right-most version component to increment: 5.93, 5.100)

required_version is required version of terraform
*/