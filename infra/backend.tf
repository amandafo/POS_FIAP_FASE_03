terraform {
  backend "s3" {
    key          = "fase-03/homolog/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
