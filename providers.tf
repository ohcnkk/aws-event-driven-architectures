provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.token

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
