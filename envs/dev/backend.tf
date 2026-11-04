terraform {
  backend "s3" {
    bucket       = "novasphere-tfstate-mkh"
    key          = "novasphere/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
